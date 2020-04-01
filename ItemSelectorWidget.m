//
//  ItemSelectorWidget.m
//  Board3
//
//  Created by Dror Kessler on 6/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ItemSelectorWidget.h"
#import "GridBoard.h"
#import "SoundTheme.h"
#import "ScoreWidget.h"
#import "SymbolPiece.h"
#import "TextSpeaker.h"
#import "CompoundBoard.h"
#import "Catalog.h"
#import "CatalogItem.h"
#import "Folders.h"
#import "PrefPromotedCatalogItemsPage.h"
#import "CompoundBoard.h"
#import "L.h"

#define	PIECE_ENTRY_KEY		@"ItemSelectorWidget_EntryKey"

#define PROMOS				([[BrandManager currentBrand] globalBoolean:@"catalog/props/promote-on-levels" withDefaultValue:FALSE])



@interface ItemSelectorEntry : NSObject
{
	NSString*			_title;
	NSString*			_shortDescription;
	int					entryIndex;
	id<NSObject>		_target;
	SEL					action;
	BOOL				enabled;
	BOOL				checked;
	BOOL				checked2;
	NSMutableDictionary* _props;
	NSString*			_label;
}
@property (retain) NSString* title;
@property (retain) NSString* shortDescription;
@property int entryIndex;
@property (nonatomic,assign) id<NSObject> target;
@property SEL action;
@property BOOL enabled;
@property BOOL checked;
@property BOOL checked2;
@property (retain) NSMutableDictionary* props;
@property (retain) NSString* label;
@end
@implementation ItemSelectorEntry
@synthesize title = _title;
@synthesize shortDescription = _shortDescription;
@synthesize entryIndex;
@synthesize target = _target;
@synthesize action;
@synthesize enabled;
@synthesize checked;
@synthesize checked2;
@synthesize props = _props;
@synthesize label = _label;

-(void)dealloc
{
	[_title release];
	[_shortDescription release];
	[_props release];
	
	[super dealloc];
}

@end

@implementation ItemSelectorWidget
@synthesize items = _items;
@synthesize board = _board;
@synthesize panel = _panel;
@synthesize soundTheme = _soundTheme;
@synthesize view = _view;
@synthesize cellSize;
@synthesize speakSelection;
@synthesize hideDisabledItems;
@synthesize boardFormula = _boardFormula;


-(id)init
{
	if ( self = [super init] )
	{
		cellSize = 48;
		self.items = [[[NSMutableArray alloc] init] autorelease];
		self.soundTheme = [SoundTheme singleton];
	}
	return self;
}

-(void)dealloc
{
	[_items release];
	
	for ( id<Piece> p in [_board allPieces] )
		[p setEventsTarget:nil];
	[_board release];
	
	[_panel setEventsTarget:nil];
	[_panel release];
	
	[_soundTheme release];
	[_view release];
	
	[_boardFormula release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( _view == NULL )
	{
		if ( !PROMOS )
		{
			if ( !_boardFormula )
				self.board = [[[GridBoard alloc] initWithWidth:6 andHeight:6] autorelease];
			else
				self.board = [CompoundBoard boardByFormula:_boardFormula];
		}
		else
			self.board = [CompoundBoard boardByFormula:@"0 0 60 60 6 4\n0 240 180 120 2 1"];
		
		self.panel = [[[ScoreWidget alloc] init] autorelease];
		
		self.view = [[[UIView alloc] initWithFrame:frame] autorelease];

		CGRect		boardRect = {{16,56}, {289,289}};
		[_view addSubview:[_board viewWithFrame:boardRect]];
		
		CGRect		panelRect = {{16,360}, {289,48}};
		[_view addSubview:[_panel viewWithFrame:panelRect]];
				
	}
	return _view;
}

-(int)addItem:(NSString*)title andShortDescription:(NSString*)shortDescription
{
	ItemSelectorEntry*		entry = [[[ItemSelectorEntry alloc] init] autorelease];
	
	entry.entryIndex = [_items count];
	entry.title = title;
	entry.shortDescription = shortDescription;
	[_items addObject:entry];
	
	return [_items count] - 1;
}

-(void)setItemAction:(SEL)action withTarget:(id<NSObject>)target atIndex:(int)index
{
	ItemSelectorEntry*		entry = [_items objectAtIndex:index];
	
	entry.target = target;
	entry.action = action;
}

-(void)setItemEnabled:(BOOL)enabled atIndex:(int)index
{	
	ItemSelectorEntry*		entry = [_items objectAtIndex:index];

	entry.enabled = enabled;
	
	if ( painted )
	{
		id<Piece>	piece = [_board pieceAt:index];
		
		[piece setDisabled:!enabled];
		if ( hideDisabledItems )
			[piece setHidden:!enabled];
	}
}

-(void)setItemChecked:(BOOL)checked atIndex:(int)index
{	
	ItemSelectorEntry*		entry = [_items objectAtIndex:index];
	
	entry.checked = checked;
	
	if ( painted )
	{
		id<Piece>	piece = [_board pieceAt:index];
		
		if ( checked && !entry.checked2 )
			[piece addDecorator:DECORATOR_CHECKED];
		else
			[piece removeDecorator:DECORATOR_CHECKED];
	}
}

-(void)setItemChecked2:(BOOL)checked atIndex:(int)index
{	
	ItemSelectorEntry*		entry = [_items objectAtIndex:index];
	
	entry.checked2 = checked;
	
	if ( painted )
	{
		id<Piece>	piece = [_board pieceAt:index];
		
		if ( checked )
			[piece addDecorator:DECORATOR_CHECKED2];
		else
			[piece removeDecorator:DECORATOR_CHECKED2];
	}
}

-(void)setItemLabel:(NSString*)label atIndex:(int)index
{	
	ItemSelectorEntry*		entry = [_items objectAtIndex:index];
	
	entry.label = label;
	
	if ( painted )
	{
		id<Piece>	piece = [_board pieceAt:index];
		
		piece.text = label;
	}
}


-(NSMutableDictionary*)itemPropsAtIndex:(int)index
{
	ItemSelectorEntry*		entry = [_items objectAtIndex:index];
	
	if ( !entry.props )
		entry.props = [NSMutableDictionary dictionary];
	
	return entry.props;
}

-(void)paintItems
{
	int		index = 0;
	
	for ( ItemSelectorEntry* entry in _items )
	{
		SymbolPiece*	piece = [[[SymbolPiece alloc] init] autorelease];
		if ( entry.label )
			piece.text = entry.label;
		else
			piece.text = [NSString stringWithFormat:@"%d", entry.entryIndex + 1];
			
		piece.eventsTarget = self;
		[piece.props setObject:entry forKey:PIECE_ENTRY_KEY];
		[piece.props setObject:[NSNumber numberWithInt:(index / 6) * 100 + index % 6] forKey:SYMBOL_PIECE_POS_COLOR_HINT];
		[_board placePiece:piece at:index++];
		
		if ( !entry.enabled )
		{
			[piece setDisabled:TRUE];
			if ( hideDisabledItems )
				[piece setHidden:TRUE];
		}
		
		if ( entry.checked && !entry.checked2 )
			[piece addDecorator:DECORATOR_CHECKED];
		else
			[piece removeDecorator:DECORATOR_CHECKED];
		
		if ( entry.checked2 )
			[piece addDecorator:DECORATOR_CHECKED2];
		else
			[piece removeDecorator:DECORATOR_CHECKED2];
	}
	
	[self reset];	
	
	painted = TRUE;
	
	if ( PROMOS )
	{
		NSArray*	items = [[Catalog currentCatalog] itemsForDomain:DF_LANGUAGES];
		if ( [items count] )
		{
			CatalogItem*	item = [items objectAtIndex:0];
			UIImage*		banner = [item bannerImage];
			SymbolPiece*	piece = [[[SymbolPiece alloc] init] autorelease];
			int				index = [_board cellCount] - 1;
			
			piece.image = banner;
			[piece.props setObject:item forKey:@"catalog-item"];
			[_board placePiece:piece at:index];
		}
	}
	
	[self startTickTimer:50];
}

-(void)reset
{
	for ( id<Piece> piece in [_board allPieces] )
		[piece deselect];	
	
	[_panel setMessage:@""];
}

-(void)appeared
{
	[self startTickTimer:50];
	[_panel updateWallet];
}

-(void)disappeared
{
	[self stopTickTimer];
}


-(void)pieceSelected:(id<Piece>)piece
{
	[self stopTickTimer];
	[_soundTheme pieceSelected];
	
	CatalogItem*			item = [piece.props objectForKey:@"catalog-item"];
	ItemSelectorEntry*		entry = [piece.props objectForKey:PIECE_ENTRY_KEY];	

	if ( entry || item )
	{
		// deselect all other pieces
		for ( id<Piece> otherPiece in [_board allPieces] )
			if ( piece != otherPiece )
				[otherPiece deselect];

		if ( item )
		{
			[_panel setMessage1:[item name]];
			[_panel setMessage2:LOC(@"Especially For You!")];
			
			if ( speakSelection )
				[TextSpeaker speak:[NSString stringWithFormat:@"%@ - %@", _panel.message2, _panel.message1]];
			
			return;
		}
		
		// update text
		[_panel setMessage1:entry.title];
		[_panel setMessage2:entry.shortDescription];
		
		// update score display offset
		NSNumber*		sdo;
		if ( entry.props && (sdo = [entry.props objectForKey:@"ScoreDisplayOffset"]) )
			[_panel setScoreDisplayOffset:[sdo intValue]];
		
		// speak?
		if ( speakSelection )
		{
			NSString*	text = [NSString stringWithFormat:@"%@ - %@", entry.title, entry.shortDescription];
			
			[TextSpeaker speak:text];
		}
	}
}	

-(void)pieceReselected:(id<Piece>)piece
{	
	CatalogItem*			item = [piece.props objectForKey:@"catalog-item"];
	ItemSelectorEntry*		entry = [piece.props objectForKey:PIECE_ENTRY_KEY];	

	if ( item )
	{
		PrefPromotedCatalogItemsPage*	page = [[[PrefPromotedCatalogItemsPage alloc] initWithCatalogItems:[NSArray arrayWithObject:item]] autorelease];
		NSLog(@"page: %@", page);
		
		return;
	}
	
	if ( entry && entry.target && entry.action )
		[entry.target performSelector:entry.action withObject:(id)entry.entryIndex withObject:self];			
}

-(void)onTickTimer
{
	[super onTickTimer];
	
	if ( [self tickCounter] < 0 )
	{
		int		index = -[self tickCounter] - 1;
		
		// deselect all
		for ( id<Piece> piece in [_board allPieces] )
			[piece deselect];			
		if ( index < [_board cellCount] )
			[[_board pieceAt:index] select];
		else
			[self setTickCounter:100];
	}
}

-(void)onTickCounterZero
{
	[super onTickCounterZero];
	
	[_soundTheme pieceHinted];
}


-(void)pieceClicked:(id<Piece>)piece
{
	
}

-(void)disabledPieceClicked:(id<Piece>)piece
{
	if ( !hideDisabledItems )
		[self pieceSelected:piece];
}

-(void)setMessage:(NSString*)message andSubMessage:(NSString*)subMessage
{
	_panel.message1 = message;
	_panel.message2 = subMessage;
}

-(int)itemCount
{
	return [_items count];
}

@end
