//
//  ScoreTableWidget.m
//  Board3
//
//  Created by Dror Kessler on 7/17/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ScoreTableWidget.h"
#import "GridBoard.h"
#import "SoundTheme.h"
#import "ScoreWidget.h"
#import "SymbolPiece.h"
#import "TextSpeaker.h"
#import "ScoresViewController.h"
#import "ScoresComm.h"
#import "NSDictionary_TypedAccess.h"
#import "BrandManager.h"

//#define DUMP

#define	SCORE_SIZE_W_BANNER		5
#define	SCORE_SIZE_WO_BANNER	6

@interface ScoreTableWidget (Privates)
-(void)resetSelections:(id<Piece>)exceptPiece;
-(void)placeBanner;
@end

@implementation ScoreTableWidget
@synthesize view = _view;
@synthesize boardA = _boardA;
@synthesize boardB = _boardB;
@synthesize panel = _panel;
@synthesize soundTheme = _soundTheme;
@synthesize scoreNumberFormatter = _scoreNumberFormatter;
@synthesize banner = _banner;

-(id)init
{
	if ( self = [super init] )
	{
		self.soundTheme = [SoundTheme singleton];
		
		self.scoreNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		[_scoreNumberFormatter setGroupingSize:3];
		[_scoreNumberFormatter setGroupingSeparator:@","];
		[_scoreNumberFormatter setUsesGroupingSeparator:TRUE];		
	}
	return self;
}

-(void)dealloc
{
	[_view release];
	
	for ( id<Piece> p in [_boardA allPieces] )
		[p setEventsTarget:nil];
	for ( id<Piece> p in [_boardB allPieces] )
		[p setEventsTarget:nil];
	
	[_boardA release];
	[_boardB release];
	
	[_panel setEventsTarget:nil];
	[_panel release];
	
	[_soundTheme release];
	[_scoreNumberFormatter release];
	[_banner release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( _view == NULL )
	{
		self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
		
		[self placeBanner];
		int		size = _banner ? SCORE_SIZE_W_BANNER : SCORE_SIZE_WO_BANNER;

		self.boardA = [[[GridBoard alloc] initWithWidth:1 andHeight:size] autorelease];
		self.boardB = [[[GridBoard alloc] initWithWidth:1 andHeight:size] autorelease];
		self.panel = [[[ScoreWidget alloc] init] autorelease];
		
		CGRect		boardARect = {{16,56 + (6 - size)*48}, {49,size * 48 + 1}};
		[_view addSubview:[_boardA viewWithFrame:boardARect]];
		CGRect		boardBRect = {{64,56 + (6 - size)*48}, {241,size * 48 + 1}};
		[_view addSubview:[_boardB viewWithFrame:boardBRect]];
		
		CGRect		panelRect = {{16,360}, {289,48}};
		[_view addSubview:[_panel viewWithFrame:panelRect]];
		
	}
	return _view;
}

-(void)reset
{
	for ( id<Piece> piece in [_boardA allPieces] )
		[piece deselect];	
	for ( id<Piece> piece in [_boardB allPieces] )
		[piece deselect];	
	
}

-(void)appeared
{
	[self startTickTimer:50];
}

-(void)disappeared
{
	[self stopTickTimer];
}


-(void)pieceSelected:(id<Piece>)piece
{
	[self stopTickTimer];
	[_soundTheme pieceSelected];
	
	[self resetSelections:piece];
	
	// update panel
	NSDictionary*	attrs = [piece.props objectForKey:@"attrs"];
	[_panel setMessage1:[attrs objectForKey:@"scoreText"]];
	[_panel setMessage2:[NSString stringWithFormat:@"Position %@", [attrs objectForKey:@"position"]]];
}	

-(void)pieceReselected:(id<Piece>)piece
{	
	[self startTickTimer:100];
	[_soundTheme pieceSelected];
	
	[self resetSelections:NULL];
}

-(void)onTickTimer
{
	[super onTickTimer];
	
	if ( [self tickCounter] < 0 )
	{
		int			index = -[self tickCounter] - 1;
		id<Board>	board = !(index % 2) ? _boardA : _boardB;
		index /= 2;
		
		// deselect all
		[self reset];
		if ( index < [_boardA cellCount] && [_boardA pieceAt:index] )
			[[board pieceAt:index] select];
		else
			[self setTickCounter:100];
	}
}

-(void)onTickCounterZero
{
	[super onTickCounterZero];
	
	[_soundTheme pieceHinted];
}

-(void)paintScores:(NSDictionary*)scores
{
	// clear
	for ( id<Piece> p in [_boardA allPieces] )
		[p eliminate];
	for ( id<Piece> p in [_boardB allPieces] )
		[p eliminate];
	
	// verify version
	if ( ![[scores stringForKey:@"version" withDefaultValue:@""] isEqualToString:NSEP_VERSION] )
		return;
	
	// access score-table
	NSDictionary*		scoreTable = [scores objectForKey:@"score-table"];
	if ( !scoreTable )
		return;
	
	// get title/sub-title
	[_panel setMessage1:[scores objectForKey:@"title"]];
	[_panel setMessage2:[scores objectForKey:@"sub-title"]];
	
	// loop on entries
	int		filledRows = 0;
	for ( NSDictionary* entry in [scoreTable arrayForKey:@"entries" withDefaultValue:[NSArray array]] )
	{
		if ( filledRows <= [_boardA cellCount] )
		{
			int						row = filledRows++;
			NSMutableDictionary*	dict = [NSMutableDictionary dictionaryWithDictionary:entry];
			
			// get score
			NSString*		scoreText = [_scoreNumberFormatter stringFromNumber:[dict objectForKey:@"score"]];
			[dict setObject:scoreText forKey:@"scoreText"];
			
			NSString*		icon = [dict stringForKey:@"icon" withDefaultValue:NULL];
			if ( icon == NULL || [icon length] == 0 )
				icon = [_scoreNumberFormatter stringFromNumber:[dict objectForKey:@"position"]];
			
			SymbolPiece*	piece = [[[SymbolPiece alloc] init] autorelease];
			[piece setText:icon];
			piece.eventsTarget = self;
			[piece.props setObject:dict forKey:@"attrs"];
			[piece.props setObject:[NSNumber numberWithInt:filledRows] forKey:SYMBOL_PIECE_POS_COLOR_HINT];
			[_boardA placePiece:piece at:0 andY:row];
			
			SymbolPiece*	piece2 = [[[SymbolPiece alloc] init] autorelease];
			[piece2 setText:[dict objectForKey:@"nick"]];
			piece2.eventsTarget = self;
			[piece2.props setObject:dict forKey:@"attrs"];
			[piece2.props setObject:[NSNumber numberWithInt:filledRows] forKey:SYMBOL_PIECE_POS_COLOR_HINT];
			[_boardB placePiece:piece2 at:0 andY:row];
		}
	}
	
	[self startTickTimer:50];
}

-(void)resetSelections:(id<Piece>)exceptPiece
{
	for ( id<Piece> piece in [_boardA allPieces] )
		if ( piece != exceptPiece )
			[piece deselect];
	for ( id<Piece> piece in [_boardB allPieces] )
		if ( piece != exceptPiece )
			[piece deselect];
}

-(void)pieceClicked:(id<Piece>)piece
{
	
}

-(void)setPanelEventsTarget:(id<ScoreWidgetEventsTarget>)eventsTarget
{
	[_panel setEventsTarget:eventsTarget];
}

-(void)placeBanner
{
	self.banner = [[BrandManager currentBrand] globalBanner:@"scores"];
	if ( _banner )
		[_banner placeOnView:_view atY:20];
}

@end
