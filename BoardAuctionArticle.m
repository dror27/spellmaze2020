//
//  BoardAuctionArticle.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BoardAuctionArticle.h"
#import "GameBoardLogic.h"
#import "GameLevel.h"
#import "CrossPieceDisabler.h"
#import "NSArray_Random.h"
#import "Alphabet.h"

extern int compare_unichars(const void * a, const void * b);

@implementation BoardAuctionArticle
@synthesize leadingPiece = _leadingPiece;

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
	if ( _symbols )
		free(_symbols);
	
	[_leadingPiece release];
	
	[super dealloc];
}

-(void)prepareForBids
{
	if ( _symbols )
	{
		free(_symbols);
		_symbols = NULL;
		symbolCount = 0;
	}
	
	NSMutableString*		symbols = [[[NSMutableString alloc] init] autorelease];
	
	// this is a rather special case for the Disable! board logics ...
	id<GameBoardLogic>		gbl = [[_board level] logic];
	NSArray*				allPieces = [_board allPieces];
	if ( ![gbl includesRole:@"Disable!"] || ![allPieces count] )
	{
		for ( id<Piece> piece in allPieces )
			[piece appendTo:symbols];
		self.leadingPiece = nil;
		leadingSymbol = NO_SYMBOL;
	}
	else
	{
		// select a random leading piece
		self.leadingPiece = (id<Piece>)[allPieces objectAtRandomIndex];
		leadingSymbol = [[_leadingPiece text] characterAtIndex:0];
		
		// ask cross to collect pieces around it
		CrossPieceDisabler*		cross = [gbl getIncludedRole:@"Disable!"];
		NSArray*				crossPieces = [cross collectCrossPieces:_leadingPiece fromPieces:allPieces];
		for ( id<Piece> piece in crossPieces )
			[piece appendTo:symbols];
	}
	
	symbolCount = [symbols length];
	if ( symbolCount )
	{
		_symbols = malloc(symbolCount * sizeof(unichar));
		[symbols getCharacters:_symbols];
		qsort(_symbols, symbolCount, sizeof(unichar), compare_unichars);
	}
}

-(unichar*)symbols
{
	return _symbols;
}

-(int)symbolCount
{
	return symbolCount;
}

-(id<Board>)board
{
	return _board;
}

-(unichar)leadingSymbol
{
	return leadingSymbol;
}
@end
