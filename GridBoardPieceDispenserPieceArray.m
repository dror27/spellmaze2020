//
//  GridBoardPieceDispenserPieceArray.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoardPieceDispenserPieceArray.h"
#import "SymbolPiece.h"


@implementation GridBoardPieceDispenserPieceArray
@synthesize pieces = _pieces;

-(void)dealloc
{
	[_pieces release];
	
	[super dealloc];
}

-(BOOL)preparePiece
{
	if ( index < [_pieces count] )
	{
		id<Piece>		piece = [_pieces objectAtIndex:index++];
		[_ownBoard placePiece:piece at:0];
		
		return TRUE;
	}
	else
		return FALSE;
}

-(float)progress
{
	return index / [_pieces count];
}



@end
