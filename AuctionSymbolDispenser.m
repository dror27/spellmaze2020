//
//  AuctionSymbolDispenser.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AuctionSymbolDispenser.h"
#import "BoardAuctionArticle.h"
#import "AuctionRoomImpl.h"
#import "AuctionManagerImpl.h"
#import "WordAuctionParticipant.h"
#import "SymbolAuctionBid.h"
#import "GameLevel.h"
#import "AuctionManager.h"
#import "AuctionRoom.h"
#import "GameBoardLogic.h"
#import "BoardLanguageWordsAuctionUsher.h"


//#define	BYPASS

//#define	MEASURE

#ifdef MEASURE
clock_t		startedAt;
#endif

@interface AuctionSymbolDispenser (Privates)
-(void)realizeBoard;
@end



@implementation AuctionSymbolDispenser
@synthesize board = _board;
@synthesize room = _room;
@synthesize article = _article;

-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super init] )
	{
		self.board = board;		
	}
	return self;
}

-(void)dealloc
{
	[_board release];
	[_room release];
	[_article release];
	
	[super dealloc];
}

-(unichar)dispense:(NSMutableDictionary*)hints
{
#ifdef	MEASURE
	startedAt = clock();
#endif		
	
	unichar		symbol = NO_SYMBOL;
	
	[self realizeBoard];
	
	if ( [self canDispense] )
	{
		if ( [super rushDispensing] )
			symbol = [super dispense:hints];
		else
		{
#ifdef	 BYPASS
			return [super dispense:hints];
#endif
			id<AuctionBid>	bid = nil;
			int				rounds = [[[_board level] logic] includesRole:@"Disable!"] ? 4 : 1;
			
			// sell the board
			for ( ; !bid && rounds > 0 ; rounds-- )
				bid = [_room.manager sell:_article inRoom:_room];
			if ( [bid isKindOfClass:[SymbolAuctionBid class]] )
			{
				SymbolAuctionBid*		symbolBid = (SymbolAuctionBid*)bid;
				BoardAuctionArticle*	boardArticle = (BoardAuctionArticle*)_article;
				
				symbol = [symbolBid symbol];
				if ( symbol != NO_SYMBOL )
				{
					symbolsLeft--;		
					
					id<Piece>			leadingPiece = boardArticle.leadingPiece;
					if ( leadingPiece )
						[hints setObject:leadingPiece forKey:@"LeadingPiece"];
				}
				else
					symbol = [super dispense:hints];
			}
			else
				symbol = [super dispense:hints];
		}
	}
	
#ifdef	MEASURE
	NSLog(@"[AuctionSymbolDispenser] %f dispense", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
	return symbol;
}

-(BOOL)canDispense
{
	[self realizeBoard];
	
	if ( ![_room size] )
		return FALSE;
	else 
		return [super canDispense];
}

-(void)realizeBoard
{
	if ( _room )
		return;
	
	// construct room
	AuctionRoomImpl*	room = [[[AuctionRoomImpl alloc] init] autorelease];
	
	self.room = room;
	room.manager = [[[AuctionManagerImpl alloc] init] autorelease];
	room.usher = [[[BoardLanguageWordsAuctionUsher alloc] initWithBoard:_board] autorelease];
	[room.usher prepareRoomForBids:room];
	
	// create a board article
	self.article = [[[BoardAuctionArticle alloc] initWithBoard:_board] autorelease];	
}

@end
