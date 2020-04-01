//
//  OrderNudgeGBL.m
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "OrderNudgeGBL.h"
#import "GameLevel.h"
#import "Cell.h"


@implementation OrderNudgeGBL
@synthesize order = _order;

-(id)initWithBoard:(id<Board>)board andBoardOrder:(id<BoardOrder>)boardOrder
{
	if ( self = [super initWithBoard:board] )
	{
		self.order = boardOrder;
	}
	return self;
}

-(void)dealloc
{
	[_order release];
	
	[super dealloc];
}

-(BOOL)willAcceptPiece
{
	return [_board freeCellCount];
}

-(void)pieceDispensed:(id<Piece>)piece
{
	// always place at string position
	[self placePiece:piece atCellIndex:0];
}

-(void)placePiece:(id<Piece>)piece atCellIndex:(int)cellIndex
{
	// check index
	if ( cellIndex >= [_board cellCount] )
		return;
	
	// place piece
	int		index = [_order indexOfOrder:cellIndex];
	id<Piece>	oldPiece = [_board placePiece:piece at:index];
	
	// replace old piece?
	if ( oldPiece )
		[self placePiece:oldPiece atCellIndex:cellIndex + 1];
}

-(NSString*)role
{
	return @"Place!";
}
@end
