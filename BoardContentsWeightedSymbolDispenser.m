//
//  BoardContentsWeightedSymbolDispenser.m
//  Board3
//
//  Created by Dror Kessler on 8/4/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "BoardContentsWeightedSymbolDispenser.h"
#import "SymbolAlphabet.h"
#import "Board.h"
#import "Piece.h"

//#define DUMP

@interface BoardContentsWeightedSymbolDispenser (Privates)
-(id<Alphabet>)buildBoardAlphbet;
@end



@implementation BoardContentsWeightedSymbolDispenser
@synthesize board = _board;

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
	
	[super dealloc];
}

-(unichar)dispense:(NSMutableDictionary*)hints
{
	if ( [self canDispense] )
	{
		if ( [super rushDispensing] )
			return [super dispense:hints];
		
		symbolsLeft--;

		// build board alphabet
		id<Alphabet>	boardAlphabet = [self buildBoardAlphbet];

		// build factored weights
		float*			factoredWeights = alloca([_alphabet size] * sizeof(float));
		float			factoredWeightsSum = 0.0;
		for ( int symbolIndex = [_alphabet size] - 1 ; symbolIndex >= 0 ; symbolIndex-- )
		{
			float	originalWeight = [_alphabet weightAt:symbolIndex];
			float	boardWeight = [boardAlphabet weightAt:symbolIndex];
			
			//float	factor = exp2f(128 * (originalWeight - boardWeight));
			float	factor = originalWeight / MAX(boardWeight, 0.0001);
			
			float	factoredWeight = originalWeight * factor;
			
#ifdef DUMP
			if ( symbolIndex == [_alphabet size] - 1 )
				NSLog(@"dispense: SYM originalWeight boardWeight factor foctoredWeight level (100% perfect)");
			NSLog(@"dispense: '%C' %f %f %f %f %.0f%%", [_alphabet symbolAt:symbolIndex], 
				  originalWeight, boardWeight, factor, factoredWeight,
				  (originalWeight > 0.0) ? (boardWeight / originalWeight * 100.0) : 0);
#endif
			
			factoredWeightsSum += factoredWeight;
			factoredWeights[symbolIndex] = factoredWeight;
		}

		float	r = (float)rand() / RAND_MAX * factoredWeightsSum;
		for ( int symbolIndex = [_alphabet size] - 1 ; symbolIndex >= 0 ; symbolIndex-- )
		{
			float		weight = factoredWeights[symbolIndex];
			
			r -= weight;
			if ( r <= 0 )
				return [_alphabet symbolAt:symbolIndex];
		}
		
		// if here, return first symbol;
		return [_alphabet symbolAt:0];
	}
	else
		return NO_SYMBOL;
}

-(id<Alphabet>)buildBoardAlphbet
{
	// initialize symbol counts
	int					alphabetSize = [_alphabet size];
	int*				boardSymbolsCounts = alloca(alphabetSize * sizeof(int));
	for ( int symbolIndex = 0 ; symbolIndex < alphabetSize ; symbolIndex++ )
		boardSymbolsCounts[symbolIndex] = 0.0;
	
	// loop on board pieces
	NSMutableString*	symbol = [[[NSMutableString alloc] init] autorelease];
	for ( id<Piece> piece in [_board allPieces] )
	{
		[symbol setString:@""];
		[piece appendTo:symbol];
		int		symbolIndex = [_alphabet symbolIndex:[symbol characterAtIndex:0]];
		if ( symbolIndex < 0 || symbolIndex >= alphabetSize )
			continue;
		boardSymbolsCounts[symbolIndex]++;
	}
	
	// build new alphabet
	SymbolAlphabet*		boardAlphabet = [[[SymbolAlphabet alloc] init] autorelease];
	for ( int symbolIndex = 0 ; symbolIndex < alphabetSize ; symbolIndex++ )
		[boardAlphabet addSymbol:[_alphabet symbolAt:symbolIndex] withCount:boardSymbolsCounts[symbolIndex]];
	
	// dump?
#ifdef	DUMP
	for ( int symbolIndex = 0 ; symbolIndex < alphabetSize ; symbolIndex++ )
		NSLog(@"buildBoardAlphbet: '%C' - %f", [boardAlphabet symbolAt:symbolIndex], [boardAlphabet weightAt:symbolIndex]);
#endif
	
	
	return boardAlphabet;
}



@end
