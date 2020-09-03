//
//  GameBoardLogicBase.h
//  Board3
//
//  Created by Dror Kessler on 5/25/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardLogic.h"
#import "Board.h"


@interface GameBoardLogicBase : NSObject<GameBoardLogic> {

	id<Board>			_board;

}
@property (retain) id<Board> board;

-(id)initWithBoard:(id<Board>)board;

@end
