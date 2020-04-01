//
//  GoalSeekingSymbolDispenser.h
//  Board3
//
//  Created by Dror Kessler on 7/16/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RandomSymbolDispenser.h"
#import "Board.h"
#import "BoardPotentialFunction.h"


@interface GoalSeekingSymbolDispenser : RandomSymbolDispenser {

	id<Board>						_board;
	id<BoardPotentialFunction>		_boardPotentialFunction;
	
	int								maxLookahead;
	
	enum		{IDLE = 0, COMPUTING, DONE} state;
	unichar							computedSymbol;
	unichar							nextSymbolWhenStartedCompute;
	NSString*						_boardSymbols;
}
@property (retain) id<Board> board;
@property (retain) id<BoardPotentialFunction> boardPotentialFunction;
@property (retain) NSString* boardSymbols;
@property int maxLookahead;

@end
