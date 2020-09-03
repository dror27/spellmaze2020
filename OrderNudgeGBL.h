//
//  OrderNudgeGBL.h
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardOrder.h"
#import "GameBoardLogic.h"
#import "GameBoardLogicBase.h"
#import "Board.h"

@interface OrderNudgeGBL : GameBoardLogicBase {

	id<BoardOrder>	_order;
}
@property (retain) id<BoardOrder> order;

-(id)initWithBoard:(id<Board>)board andBoardOrder:(id<BoardOrder>)boardOrder;
-(void)placePiece:(id<Piece>)piece atCellIndex:(int)cellIndex;

@end
