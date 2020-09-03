//
//  MainMenuWidget.m
//  Board3
//
//  Created by Dror Kessler on 6/13/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "MainMenuWidget.h"
#import "CompoundBoard.h"
#import "GridBoard.h"
#import "SymbolPiece.h"
#import "GridBoardPieceDispenserPieceArray.h"
#import "OrderNudgeGBL.h"
#import "SimpleBoardOrder.h"	
#import "GameLevel.h"
#import "TextSpeaker.h"
#import "BrandManager.h"
#import "Banner.h"
#import "GameLevelSequence.h"
#import "GameManager.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"
#import "ImageWithUUID.h"
#import "UUIDUtils.h"
#import "ScoresDatabase.h"
#import "ViewController.h"

extern time_t		appStartedAt;


#define	PIECE_ENTRY_KEY			@"MainMenuWidget_EntryKey"
#define	PIECE_GAME_UUID			@"MainMenuWidget_GameUUID"
#define	PIECE_GAME_SELECTION	@"MainMenuWidget_GameSelection"


#define	NUDGE		0

@interface MainMenuEntry : NSObject
{
	NSString*		_text;
	id<Board>		_board;
	CGRect			frame;
	int				entryIndex;
	id<NSObject>	_target;
	SEL				action;
}
@property (retain) NSString* text;
@property (retain) id<Board> board;
@property CGRect frame;
@property int entryIndex;
@property (nonatomic,assign) id<NSObject> target;
@property SEL action;
@end
@implementation MainMenuEntry
@synthesize text = _text;
@synthesize board = _board;
@synthesize frame;
@synthesize entryIndex;
@synthesize target = _target;
@synthesize action;

-(void)dealloc
{
	[_text release];
	
	for ( id<Piece> p in [_board allPieces] )
		[p setEventsTarget:nil];
	[_board release];
	
	[super dealloc];
}

@end

@interface MainMenuWidget (Privates)
-(void)placeBanner;
-(void)placePrefButton;
-(void)placeGameSelection;
-(UIImage*)languageGameIcon:(NSString*)uuid;
@end


@implementation MainMenuWidget
@synthesize entries = _entries;
@synthesize view = _view;
@synthesize dispenserView = _dispenserView;
@synthesize mainBoard = _mainBoard;
@synthesize mainBoardGBL = _mainBoardGBL;
@synthesize soundTheme = _soundTheme;
@synthesize timer = _timer;
@synthesize preferencesTarget = _preferencesTarget;
@synthesize cellSize;
@synthesize banner = _banner;
@synthesize prefButton = _prefButton;
@synthesize disabled;
@synthesize tickWaveImage = _tickWaveImage;
@synthesize gameSelectionBoard = _gameSelectionBoard;
@synthesize gameSelectionUUIDs = _gameSelectionUUIDs;

-(id)init
{
	if ( self = [super init] )
	{
        cellSize = [ViewController adjWidth:48];
		self.entries = [[[NSMutableArray alloc] init] autorelease];
		self.soundTheme = [SoundTheme singleton];
	}
	return self;
}

-(void)dealloc
{
	for ( MainMenuEntry* entry in _entries )
		[entry setTarget:nil];
	[_entries release];

	[_view release];
	[_dispenserView release];
	[_mainBoard release];
	[_mainBoardGBL release];
	[_soundTheme release];
	[_timer release];
	[_preferencesTarget release];
	[_banner release];
	[_prefButton release];
	[_tickWaveImage release];
	[_gameSelectionBoard release];
	[_gameSelectionUUIDs release];

	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( _view == NULL )
	{
		// create compound board for the entries
		self.mainBoard = [[[CompoundBoard alloc] init] autorelease];
		for ( MainMenuEntry* entry in _entries )
		{
			int		width = [entry.text length];
			
			// for each entry, create a grid board
			entry.board = [[[GridBoard alloc] initWithWidth:width andHeight:1] autorelease];
			
			// adjust cell width?
			int		cellWidth = cellSize;
			if ( width > 6 )
				cellWidth = (cellWidth * 6) / width;
			
			// calculate frame
			CGRect	entryFrame;
			entryFrame.size.height = cellSize + 1;
			entryFrame.size.width = width * cellWidth + 1;
			entryFrame.origin.x = round((frame.size.width - entryFrame.size.width) / 2);
			entryFrame.origin.y = round((entry.entryIndex + 0.5) * (cellSize * 1.8));
			entry.frame = entryFrame;
			
			[_mainBoard addBoard:entry.board withFrame:entry.frame];
		}
		
		self.view = [_mainBoard viewWithFrame:frame];
		
		SimpleBoardOrder*		order = [[[SimpleBoardOrder alloc] initWithBoard:_mainBoard] autorelease];
		self.mainBoardGBL = [[[OrderNudgeGBL alloc] initWithBoard:_mainBoard andBoardOrder:order] autorelease];
		
		[self placeBanner];
		[self placeGameSelection];
		[self placePrefButton];
		[[BrandManager singleton] addDelegate:self];
	}	
	return _view;
}

-(void)doPref:(id)sender
{
	if ( disabled )
		return;
	
	[_soundTheme pieceSelected];
	
	disabled = TRUE;
	[_preferencesTarget performSelector:preferencesAction withObject:sender];					
}

-(int)addEntry:(NSString*)text
{
	MainMenuEntry*		entry = [[[MainMenuEntry alloc] init] autorelease];
	
	entry.entryIndex = [_entries count];
	entry.text = text;
	[_entries addObject:entry];
	
	return [_entries count] - 1;
}

-(void)setEntryAction:(SEL)action withTarget:(id<NSObject>)target atIndex:(int)index
{
	MainMenuEntry*		entry = [_entries objectAtIndex:index];
	
	entry.target = target;
	entry.action = action;
}

-(void)paintEntries
{
	// prepare pieces array
#if NUDGE
	NSMutableArray*		pieces = [[[NSMutableArray alloc] init] autorelease];
#endif
	
	int					row = 0;	
	for ( MainMenuEntry* entry in _entries )
	{
		int		width = [entry.text length];
		
		for ( int index = 0 ; index < width ; index++ )
		{
			SymbolPiece*	piece = [[[SymbolPiece alloc] init] autorelease];
			piece.symbol = [entry.text characterAtIndex:index];
			
			piece.eventsTarget = self;
			[piece.props setObject:entry forKey:PIECE_ENTRY_KEY];
			[piece.props setObject:[NSNumber numberWithInt:row * 100 + index] forKey:SYMBOL_PIECE_POS_COLOR_HINT];

#if NUDGE
			[pieces insertObject:piece atIndex:0];
#else
			[entry.board placePiece:piece at:index];
#endif
		}
		
		row++;
	}
	
#if NUDGE
	// create dispenser
	GridBoardPieceDispenserPieceArray*		dispenser = [[[GridBoardPieceDispenserPieceArray alloc] init] autorelease];
	dispenser.pieces = pieces;
	dispenser.dispensingTickPeriod = 0.34;
	CGRect									rect = {{2,2}, {49,49}};
	self.dispenserView = [dispenser viewWithFrame:rect];
	[_view addSubview:dispenserView];
	[dispenser startDispensing:self andContext:NULL];
#endif
	
	[self startTickTimer:50];
}

-(void)reset
{
	for ( id<Piece> piece in [_mainBoard allPieces] )
		[piece deselect];
	for ( id<Piece> piece in [_gameSelectionBoard allPieces] )
		[piece deselect];
}

-(void)willAppear
{	
	[self placeGameSelection];
}


-(void)appeared
{
	disabled = FALSE;
	
	GameLevelSequence*	seq = [GameManager currentGameLevelSequence];
	
	self.tickWaveImage = [self languageGameIcon:seq.language.uuid];
	
	[self startTickTimer:50];
}

-(void)disappeared
{
	disabled = TRUE;
	[self stopTickTimer];
}

-(void)pieceSelected:(id<Piece>)piece
{
	if ( disabled )
		return;
	
	[self stopTickTimer];
	
	MainMenuEntry*		entry = nil;
	
	// game selection?
	if ( [piece.props hasKey:PIECE_GAME_SELECTION] )
	{
		[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_STORE withTimeDelta:time(NULL) - appStartedAt];

		[self performSelector:@selector(doPref:) withObject:self afterDelay:0.5];
		return;
	}
	if ( [piece.props hasKey:PIECE_GAME_UUID] )
	{
		if ( [[UserPrefs getString:PK_LANG_DEFAULT withDefault:@""] isEqualToString:[piece.props objectForKey:PIECE_GAME_UUID]] )
			[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_GAME1 withTimeDelta:time(NULL) - appStartedAt];
		else
			[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_GAME2 withTimeDelta:time(NULL) - appStartedAt];
			
		[UserPrefs setString:PK_LANG_DEFAULT withValue:[piece.props objectForKey:PIECE_GAME_UUID]];
		
		entry = [_entries objectAtIndex:0];
	}
	else
		entry = [piece.props objectForKey:PIECE_ENTRY_KEY];
	[_soundTheme pieceSelected];
	
	// reset all selections not on the same entry, select all pieces on the entry
	for ( id<Piece> piece in [_mainBoard allPieces] )
	{
		if ( [[piece cell] board] == entry.board )
			[piece select];
		else
			[piece deselect];
	}
	disabled = TRUE;
	
	// speak it
	[TextSpeaker speak:entry.text];
	
	// execute action after a timeout
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(executeEntryAction) userInfo:entry repeats:NO];}

-(void)executeEntryAction
{
	MainMenuEntry*		entry = [_timer userInfo];
	
	if ( entry && entry.target && entry.action )
		[entry.target performSelector:entry.action withObject:self];			
}

-(void)pieceReselected:(id<Piece>)piece {}
-(void)onDispensingStarted {}
-(void)onDispensingStopped {}
-(void)onNoMorePieces
{
	[_dispenserView removeFromSuperview];
}
-(BOOL)onWillAcceptPiece { return TRUE; }

-(void)onPieceDispensed:(id<Piece>)piece withContext:(void*)context
{
	//[soundTheme pieceDispensed];
	[_mainBoardGBL pieceDispensed:piece];
}

-(void)onTickTimer
{
	[super onTickTimer];
	
	if ( [self tickCounter] < 0 )
	{
		int		index = -[self tickCounter] - 1;
		
		// deselect all
		for ( SymbolPiece* piece in [_mainBoard allPieces] )
		{
			[piece deselect];			
			if ( piece.image )
				piece.image = nil;
		}
		if ( index < [_mainBoard cellCount] )
		{
			SymbolPiece*	piece = [_mainBoard pieceAt:index];
			
			piece.image = _tickWaveImage;
			[piece select];
		}
		else
			[self setTickCounter:100];
	}
}

-(void)onTickCounterZero
{
	[super onTickCounterZero];
	
	[_soundTheme pieceHinted];
}

-(float)targetFullness
{
	return 1.0;		// always full
}

-(float)targetProgress
{
	return 0.0;
}

-(void)pieceClicked:(id<Piece>)piece
{
	
}

-(void)setPreferencesAction:(SEL)action withTarget:(id<NSObject>)target
{
	preferencesAction = action;
	self.preferencesTarget = target;
}

-(void)brandDidChange:(Brand*)brand
{
	if ( _banner )
		[_banner removeFromView];
	[self placeBanner];

	[self placeGameSelection];
	
	if ( _prefButton )
		[_prefButton removeFromSuperview];
	[self placePrefButton];
	
}

-(void)placeGameSelection
{
	// ignore if banner present
	if ( _banner )
	{
		if ( _gameSelectionBoard )
		{
			[[_gameSelectionBoard view] removeFromSuperview];
			self.gameSelectionBoard = nil;
		}
		return;
	}
	
	
	// determins uuids of games to display
	GameLevelSequence*		seq = [GameManager currentGameLevelSequence];
	NSMutableString*		uuids = [NSMutableString stringWithString:seq.language.uuid];
	NSString*				prev = [UserPrefs getString:PK_LANG_DEFAULT_PREV withDefault:nil];
	if ( prev && ![prev isEqualToString:uuids] )
		[uuids appendFormat:@",%@", prev];
	else for ( NSString* folder in [Folders listUUIDSubFolders:NULL forDomain:DF_LANGUAGES] )
	{
		NSString*	uuid = [folder lastPathComponent];
		if ( ![uuid isEqualToString:seq.language.uuid] )
		{
			[uuids appendFormat:@",%@", uuid];
			break;
		}
	}
	
	// if still same games, escape
	if ( _gameSelectionBoard && [uuids isEqualToString:_gameSelectionUUIDs] )
		return;
	
	// remove current one
	if ( _gameSelectionBoard )
	{
		[[_gameSelectionBoard view] removeFromSuperview];
		self.gameSelectionBoard = nil;
	}
	self.gameSelectionUUIDs = uuids;
	self.gameSelectionBoard = [CompoundBoard boardByFormula:@"0 0 90 90 3 1"];
	NSArray*	uuidComps = [uuids componentsSeparatedByString:@","];
	
	CGRect		frame = _gameSelectionBoard.suggestedFrame;
	frame.origin.y = [ViewController adjWidth:300];
    frame.origin.x = round((self.view.frame.size.width - frame.size.width) / 2);
	[_view addSubview:[_gameSelectionBoard viewWithFrame:frame]];
	
	// put current game in spot on
	SymbolPiece*			piece = [[[SymbolPiece alloc] init] autorelease];
	piece.image = [self languageGameIcon:[uuidComps objectAtIndex:0]];
	piece.eventsTarget = self;
	[piece.props setObject:[uuidComps objectAtIndex:0] forKey:PIECE_GAME_UUID];
	[_gameSelectionBoard placePiece:piece at:0];

	
	// pick another language game which is not the current (who?)
	if ( [uuidComps count] > 1 )
	{
		piece = [[[SymbolPiece alloc] init] autorelease];
		piece.image = [self languageGameIcon:[uuidComps objectAtIndex:1]];
		piece.eventsTarget = self;
		[piece.props setObject:[uuidComps objectAtIndex:1] forKey:PIECE_GAME_UUID];
		[_gameSelectionBoard placePiece:piece at:1];		
	}
	
	// put generic game selection on last
	piece = [[[SymbolPiece alloc] init] autorelease];
	piece.image = [self languageGameIcon:nil];
	piece.eventsTarget = self;
	[piece.props setObject:[NSNumber numberWithBool:TRUE] forKey:PIECE_GAME_SELECTION];
	[_gameSelectionBoard placePiece:piece at:2];
}

-(void)placeBanner
{
	self.banner = [[BrandManager currentBrand] globalBanner:@"main"];
	if ( _banner )
		[_banner placeOnView:_view atY:[[BrandManager currentBrand] globalInteger:@"skin/props/banner-y" withDefaultValue:300] ];
}

-(void)placePrefButton
{
	UIButtonType		buttonType = UIButtonTypeInfoLight;
	if ( [[BrandManager currentBrand] globalBoolean:@"skin/props/grid-line-width" withDefaultValue:FALSE] )
		buttonType = UIButtonTypeInfoDark;
	self.prefButton = [UIButton buttonWithType:buttonType];
	
    _prefButton.frame = CGRectMake(self.view.frame.size.width-20-25, [ViewController adjWidth:390-25], 25.0, 25.0);
	[_prefButton setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
	_prefButton.backgroundColor = [UIColor clearColor];
	[_prefButton addTarget:self action:@selector(doPref:) forControlEvents:UIControlEventTouchUpInside];
	
	if ( buttonType == UIButtonTypeInfoDark )
		_prefButton.showsTouchWhenHighlighted = TRUE;
	
	[_view addSubview:_prefButton];	
}

-(id<Language>)targetLanguage
{
	return NULL;
}

-(int)entryCount
{
	return [_entries count];
}

-(UIImage*)languageGameIcon:(NSString*)uuid
{
	ImageWithUUID*		icon = nil;
	
	if ( uuid )
	{
		NSDictionary*		props = [Folders findUUIDProps:NULL forDomain:DF_LANGUAGES withUUID:uuid];
		NSString*			path = [[props stringForKey:@"__baseFolder" withDefaultValue:@""] stringByAppendingPathComponent:[props objectForKey:@"item-icon"]];
		
		icon = [[[ImageWithUUID alloc] initWithContentsOfFile:path] autorelease];
	}
	
	if ( !icon )
		icon = [[[ImageWithUUID alloc] initWithCGImage:[UIImage imageNamed:@"ProgramIcon1.png"].CGImage] autorelease];

	icon.uuid = [UUIDUtils createUUID];

	return icon;
}

@end
