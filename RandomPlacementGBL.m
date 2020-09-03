//
//  RandomPlacementBoardLogic.m
//  Board3
//
//  Created by Dror Kessler on 5/22/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "RandomPlacementGBL.h"
#import "GameLevel.h"
#import "GridBoard.h"

@implementation RandomPlacementGBL
@synthesize alwaysRandomPlacement;
@synthesize pauseAtWordEnd;
@synthesize pauseSkipCount;

-(id)initWithBoard:(id<Board>)board
{
	alwaysRandomPlacement = FALSE;
	pauseAtWordEnd = TRUE;
	pauseSkipCount = 0;

	return [super initWithBoard:board];
}

-(BOOL)willAcceptPiece
{
	return [_board freeCellCount];
}

-(void)pieceDispensed:(id<Piece>)piece
{
	int			index;
	
	// access hints
	id<PieceDispensingHints>	hints = [[piece props] objectForKey:@"hints"];
	if ( hints && [hints hasHint:@"WordSymbolIndex"] )
	{
		BOOL		rtl = [_board.level.language rtl];
		
		BOOL		smallBoard = FALSE;
		if ( [_board isKindOfClass:[GridBoard class]] )
			if ( ((GridBoard*)_board).width <= 4 )
				smallBoard = TRUE;

		
		NSString*	word = [hints stringHint:@"Word"];
		int			wordSize = [hints intHint:@"WordSize"];
		int			wordDispensingIndex = [hints intHint:@"WordDispensingIndex"];
		int			ofs = (wordSize <= 4 && !smallBoard) ? 1 : 0;
		int			wordIsLast = [hints intHint:@"WordIsLast"];
		
		// TODO remove hack ...
		if ( !alwaysRandomPlacement )
		{
			int		cols;
			
			if ( [_board isKindOfClass:[GridBoard class]] )
				cols = ((GridBoard*)_board).width;
			else
				cols = 6;
			
			if ( !rtl )
				index = 2 * cols + ofs + wordDispensingIndex;
			else
				index = 2 * cols + (cols-1) - ofs - wordDispensingIndex;
		}
		else
			index = [_board randomFreeCellIndex];
		
		// end of word?
		if ( wordSize == (wordDispensingIndex + 1) )
		{
			if ( (pauseAtWordEnd && !pauseSkipCount) || wordIsLast )
				[[_board level] pauseGame];
			pauseSkipCount = MAX(0, pauseSkipCount - 1);
			[[[_board level] wordValidator] wordDispensed:word];
		}
	}
	else
	{
		index = [_board randomFreeCellIndex];
	}
	
	[_board placePiece:piece at:index];			
}

-(NSString*)role
{
	return @"Place!";
}

@end
