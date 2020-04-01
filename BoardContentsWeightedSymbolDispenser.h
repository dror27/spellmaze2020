//
//  BoardContentsWeightedSymbolDispenser.h
//  Board3
//
//  Created by Dror Kessler on 8/4/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RandomSymbolDispenser.h"

@protocol Board;

@interface BoardContentsWeightedSymbolDispenser : RandomSymbolDispenser {
	
	id<Board>			_board;
}
@property (retain) id<Board> board;

-(id)initWithBoard:(id<Board>)board;

@end
