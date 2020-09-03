//
//  BoardLanguageWordsAuctionUsher.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/24/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "BoardLanguageWordsAuctionUsher.h"
#import "GameLevel.h"
#import "WordAuctionParticipant.h"

//#define DUMP

@interface BoardLanguageWordsAuctionUsher (Privates)
-(void)initialize;
-(BOOL)hasMoreQueuedWords;
-(NSString*)nextQueuedWord:(int*)wordIndexReturn;
@end


@implementation BoardLanguageWordsAuctionUsher
@synthesize board = _board;
@synthesize language = _language;
@synthesize wordQueue = _wordQueue;


-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super init] )
	{
		_board = board;
	}
	return self;
}

-(void)dealloc
{
	[_wordQueue release];
	
	[super dealloc];
}

-(void)prepareRoomForBids:(id<AuctionRoom>)room;
{
	// initialize?
	if ( !didInitialize )
		[self initialize];
	
	// room missing a word and we have one, add it
	while ( [room size] < [room capacity] && [self hasMoreQueuedWords] )
	{
		// get next word in queue
		int			wordIndex = -1;
		NSString*	word = [self nextQueuedWord:&wordIndex];
		if ( !word )
			break;
		
		// find out its index in the language
		if ( wordIndex < 0 )
			wordIndex = [_language wordIndex:word];
		if ( wordIndex < 0 )
			break;
#ifdef DUMP
		NSLog(@"[BoardLanguageWordsAuctionUsher] - letting word in: %@", word);
#endif
		
		[room addParticipant:[[[WordAuctionParticipant alloc] initWithWord:word andWordIndex:wordIndex] autorelease]];
	}	
}

-(void)initialize
{
	// access board/level/language
	GameLevel*		level = [_board level];
	
	_language = [level language];
	minWordSize = [level minWordSize];
		
	didInitialize = TRUE;
}

-(BOOL)hasMoreQueuedWords
{
	// simple case
	if ( _wordQueue && [_wordQueue hasWords] )
		return TRUE;
	
	// move to next queue
	if ( !nextWordQueueWordSize )
	{
		nextWordQueueWordSize = minWordSize;
		if ( !nextWordQueueWordSize )
			nextWordQueueWordSize = 2;
	}
	else if ( nextWordQueueWordSize < [_language maxWordSize] )
		nextWordQueueWordSize++;
	else
	{
		self.wordQueue = nil;
		return FALSE;
	}

	self.wordQueue = [[[WordQueue alloc] initWithLanguageWords:_language withMinSize:nextWordQueueWordSize
													andMaxSize:nextWordQueueWordSize andBlackList:[[_board level] blackList]] autorelease];
	return [self hasMoreQueuedWords];
}

-(NSString*)nextQueuedWord:(int*)wordIndexReturn
{
	if ( ![self hasMoreQueuedWords] )
		return nil;
	if ( !_wordQueue )
		return nil;
	
	NSString*	word = [_wordQueue nextWord];
	int			index = [_language wordIndex:word];

	// return
	if ( wordIndexReturn )
		*wordIndexReturn = index;
	return word;
}

@end
