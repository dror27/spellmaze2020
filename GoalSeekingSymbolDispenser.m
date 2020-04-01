//
//  GoalSeekingSymbolDispenser.m
//  Board3
//
//  Created by Dror Kessler on 7/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GoalSeekingSymbolDispenser.h"
#import "BPF_Entry.h"
#import "GameLevel.h"
#import "SystemUtils.h"
#import "NSMutableString_Shuffle.h"
#import "JokerUtils.h"

@interface GoalSeekingSymbolDispenser (Privates)
-(void)startCompute:(unichar)nextSymbol;
-(void)computeThread:(void*)arg;
-(NSArray*)orderedSymbolEntries:(BPF_Entry*)prefixEntry;
-(unichar)pickTopSymbol:(NSArray*)fromSymbolEntries usingLookahead:(int)lookahead;
-(unichar)recover;
-(NSString*)gatherBoardSymbols;
@end


@implementation GoalSeekingSymbolDispenser
@synthesize board = _board;
@synthesize boardPotentialFunction = _boardPotentialFunction;
@synthesize maxLookahead;
@synthesize boardSymbols = _boardSymbols;

#define		SEED_SYMBOL		'\0'

//#define	SYNC

//#define		DUMP

-(void)dealloc
{
	[_board release];
	[_boardPotentialFunction release];
	[_boardSymbols release];
	
	[super dealloc];
}

-(unichar)dispense:(NSMutableDictionary*)hints
{
	if ( [super rushDispensing] )
		return [super dispense:hints];
	
	unichar		nextSymbol = '\0';

#ifdef SYNC
	@synchronized (self) {
#endif
		
	
	if ( SEED_SYMBOL && [_board isEmpty] )
		nextSymbol = SEED_SYMBOL;

	switch ( state )
	{
		case IDLE :
		{
#ifdef DUMP
			NSLog(@"GoalSeekingSymbolDispenser: dispense - IDLE");
#endif
			
			if ( !nextSymbol )
				nextSymbol = [self recover];
			
			// start compute
			[self startCompute:nextSymbol];
			
			break;
		}
			
		case COMPUTING :
		{
#ifdef DUMP
			NSLog(@"GoalSeekingSymbolDispenser: dispense - COMPUTING");
#endif

			// not enough time ... still computing ... return 
			nextSymbol = [self recover];
			
			break;
		}
			
		case DONE :
		{
#ifdef DUMP
			NSLog(@"GoalSeekingSymbolDispenser: dispense - DONE");
#endif
			nextSymbol = computedSymbol;
			if ( nextSymbol == NO_SYMBOL )
				nextSymbol = [self recover];
			else
				symbolsLeft--;
			
			// start compute for next time
			[self startCompute:nextSymbol];
		
			break;
		}
			
		default :
			nextSymbol = [self recover];
			break;
	}
#ifdef SYNC
	}
#endif
	return nextSymbol;
}

-(void)startCompute:(unichar)nextSymbol
{
	nextSymbolWhenStartedCompute = nextSymbol;
	state = COMPUTING;
	
	NSArray*		keepAlive = [NSArray arrayWithObjects:_board, [_board level], [[_board level] language], NULL];
	
	[SystemUtils threadWithTarget:self selector:@selector(computeThread:) object:keepAlive];
	//[NSThread detachNewThreadSelector:@selector(computeThread:) toTarget:self withObject:keepAlive];	
}

-(void)computeThread:(void*)arg
{
#ifdef SYNC
	@synchronized (self) {
#endif		
	NSAutoreleasePool*		pool = [[NSAutoreleasePool alloc] init];

	// collect pieces from board
	self.boardSymbols = [self gatherBoardSymbols];
	
#ifdef DUMP
	NSLog(@"GoalSeekingSymbolDispenser: computeThread - STARTED");	
#endif
	computedSymbol = [self pickTopSymbol:[self orderedSymbolEntries:NULL] usingLookahead:maxLookahead];
#ifdef DUMP
	NSLog(@"GoalSeekingSymbolDispenser: computeThread - FINISHED: '%C'", computedSymbol);	
#endif
	
	[pool release];
	
	state = DONE;
#ifdef SYNC
	}
#endif
}

-(NSArray*)orderedSymbolEntries:(BPF_Entry*)prefixEntry;
{
	id<Language>		language = [[_board level] language];
	
	return [_boardPotentialFunction potentialsFor:_boardSymbols withSymbolFromLanguage:language 
								 
								  withPrefixEntry:prefixEntry withMinSize:[[_board level] minWordSize]  andBlackList:[[_board level] blackList]];
}

-(unichar)pickTopSymbol:(NSArray*)fromSymbolEntries usingLookahead:(int)lookahead
{
	// empty?
	if ( [fromSymbolEntries count] == 0 )
		return NO_SYMBOL;
	
	// get top score
	BPF_Entry*	entry = [fromSymbolEntries objectAtIndex:0];
	float		score = entry.score;
	int			sameScoreCount = 1;
	float		weightSum = entry.weight;
	
	// scan array, count number of entries with same score
	for ( ; sameScoreCount < [fromSymbolEntries count] ; sameScoreCount++ )
	{
		BPF_Entry*		entry2 = [fromSymbolEntries objectAtIndex:sameScoreCount];
		if ( score != entry2.score )
			break;
		
		weightSum += entry2.weight;
	}
	
	// fail on zero score
	if ( score <= 0 )
		return NO_SYMBOL;
	
	BPF_Entry*		returnedEntry = NULL;
	
	// if only one entry with same (top) score, return it
	if ( sameScoreCount == 1 )
		returnedEntry = entry;
	else if ( lookahead <= 0 || score > 0 )
	{
#ifdef	DUMP
		if ( score <= 0 )
			NSLog(@"GoalSeekingSymbolDispenser: zero (0) score - picking a random symbol?");
		NSLog(@"GoalSeekingSymbolDispenser: picking between same score of %f", score);
#endif
		
		// must resolve between same score. do this based on weight
		float	r = ((float)rand() / RAND_MAX) * weightSum;
		for ( int n = 0 ; n < sameScoreCount ; n++ )
		{
			BPF_Entry*		entry2 = [fromSymbolEntries objectAtIndex:n];
			
			r -= entry2.weight;
			if ( r <= 0 )
			{
				returnedEntry = entry2;
				break;
			}
		}
	}
	else
	{
		// recurse ...
		NSMutableArray*	entries = [[[NSMutableArray alloc] init] autorelease];
		for ( int n = 0 ; n < sameScoreCount ; n++ )
		{
			BPF_Entry*		entry2 = [fromSymbolEntries objectAtIndex:n];
			
			[entries addObjectsFromArray:[self orderedSymbolEntries:entry2]];
		}
		[entries sortUsingSelector:@selector(orderAgainst:)]; // TODO: remove sort from BPF itself?
		
		return [self pickTopSymbol:entries usingLookahead:lookahead - 1];
		
	}
	
	if ( returnedEntry )
	{
		NSString*			prefixString = [returnedEntry prefixString];
		NSMutableString*	prefixTail = [NSMutableString stringWithString:[prefixString substringFromIndex:1]];
		
		[prefixTail shuffle];
		
		[_rushSymbols appendString:prefixTail];
		symbolsLeft -= [prefixTail length];
		
		return [prefixString characterAtIndex:0];
	}
	
	// if here, something went wrong
	return NO_SYMBOL;
}

-(unichar)recover
{
	GameLevel*		level = [_board level];
	int				minSize = [level minWordSize];
	int				maxSize = [level hintMaxWordSize];
	CSetWrapper*	blackList = [level blackList];
	
	// get random word
	NSString*		randomWord = [[level language] getRandomWord:minSize withMaxSize:maxSize withBlackList:blackList];
	if ( !randomWord && maxSize )
		randomWord = [[level language] getRandomWord:minSize withMaxSize:0 withBlackList:blackList];
#ifdef DUMP
	NSLog(@"recover: %@", randomWord);
#endif
	if ( !randomWord )
		return [JokerUtils jokerCharacter];

	// sccramble its symbols
	NSMutableString*	symbols = [NSMutableString stringWithString:randomWord];
	[symbols shuffle];
	
	// check if board has enough space for this word. clean only if no word exists on the current board
	if ( [_board freeCellCount] < [symbols length] )
	{
		NSString*		boardSymbols = [self gatherBoardSymbols];
		int				charsNum = [boardSymbols length];
		unichar			*chars = alloca(charsNum + 2 * sizeof(unichar));
		[symbols getCharacters:chars];
		
		CSetWrapper		*wordsSet = [[level language] getValidWordSet:chars withCharsNum:charsNum withMinWordSize:minSize withMaxWordSize:maxSize andBlackList:blackList];
		
		if ( wordsSet.cs->size == 0 )
		{
			// clean board
			int		piecesToClear = [symbols length] + 2;
			for ( id<Piece> p in [_board allPieces] )
			{
				if ( piecesToClear-- <= 0 )
					break;
				
				[p eliminate];
			}
		}
		
	}
	
	[_rushSymbols appendString:[symbols substringFromIndex:1]];
	symbolsLeft -= [symbols length];
	
	return [symbols characterAtIndex:0];
}

-(NSString*)gatherBoardSymbols
{
	NSMutableString*		symbols = [[[NSMutableString alloc] init] autorelease];
	for ( id<Piece> piece in [_board allPieces] )
		[piece appendTo:symbols];
	if ( nextSymbolWhenStartedCompute )
		[symbols appendFormat:@"%C", nextSymbolWhenStartedCompute];

	return symbols;
}

@end
