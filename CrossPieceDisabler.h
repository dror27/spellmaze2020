//
//  CrossPieceDisabler.h
//  Board3
//
//  Created by Dror Kessler on 5/26/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardLogicBase.h"
#import "Cell.h"

@class GameLevel;

typedef enum
	{
		CROSS,
		DIAGONAL,
		HORIZONTAL,
		VERTICAL,
		ADJACENT
	} CrossType;

@interface CrossPieceDisabler : GameBoardLogicBase {

	int			centerX, centerY;
	BOOL		active;
	CrossType	type;
	BOOL		highlight;
	BOOL		progressive;
	
}
@property CrossType type;
@property BOOL highlight;
@property BOOL progressive;

-(NSArray*)collectCrossPieces:(id<Piece>)leadingPiece fromPieces:(NSArray*)pieces;


@end
