//
//  LastWordPiecesHint.m
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "LastWordPiecesHint.h"
#import "PieceDispensingHints.h"


@implementation LastWordPiecesHint
@synthesize pieces = _pieces;

-(id)init
{
	if ( self = [super init] )
	{
		wordId = 0;
		self.pieces = NULL;
	}
	return self;
}

-(void)dealloc
{
	[_pieces release];
	
	[super dealloc];
}

-(void)registerPiece:(id<Piece>)piece
{
	// has hints?
	id<PieceDispensingHints>	hints = [[piece props] objectForKey:@"hints"];
	if ( !hints )
		return;
	if ( ![hints hasHint:@"WordId"] )
		return;
	
	// same word id?
	int			pieceWordId = [hints intHint:@"WordId"];
	if ( pieceWordId != wordId )
	{
		wordSize = [hints intHint:@"WordSize"];
		
		// initialize pieces array
		self.pieces = [NSMutableArray array];
		for ( int n = 0 ; n < wordSize ; n++ )
			[_pieces addObject:[NSNull null]];
		wordId = pieceWordId;
	}
						
	// store piece
	int		index = [hints intHint:@"WordSymbolIndex"];
	if ( index < wordSize )
		[_pieces replaceObjectAtIndex:index withObject:piece];
}

-(int)size
{
	return wordSize;
}

-(id<Piece>)pieceAt:(int)index
{
	if ( index < wordSize )
		return [_pieces objectAtIndex:index];
	else
		return NULL;
}

-(id<Piece>)replacePieceAt:(int)index withPiece:(id<Piece>)newPiece
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(NSArray*)allPieces
{
	return _pieces;
}




@end
