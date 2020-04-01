//
//  ArrayPiecesHint.m
//  Board3
//
//  Created by Dror Kessler on 5/20/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ArrayPiecesHint.h"


@implementation ArrayPiecesHint
@synthesize pieces = _pieces;

-(id)initWithPieces:(NSArray*)pieces
{
	if ( self = [super init] )
	{
		self.pieces = pieces;
	}
	return self;
}

-(void)dealloc
{
	[_pieces release];
	
	[super dealloc];
}

-(int)size
{
	return [_pieces count];
}

-(id<Piece>)pieceAt:(int)index
{
	return [_pieces objectAtIndex:index];
}

-(id<Piece>)replacePieceAt:(int)index withPiece:(id<Piece>)newPiece
{
	NSMutableArray*	newPieces = [NSMutableArray arrayWithArray:_pieces];
	id<Piece>		piece = [_pieces objectAtIndex:index];
	
	// make sure piece is retain for the caller
	piece = [[piece retain] autorelease];
	
	[newPieces replaceObjectAtIndex:index withObject:newPiece];
	self.pieces = newPieces;
	
	return piece;
}

-(NSArray*)allPieces
{
	return _pieces;
}



@end
