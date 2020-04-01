//
//  SimpleBoardOrder.h
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardOrder.h"

@class GridBoard;
@protocol Board;
@interface SimpleBoardOrder : NSObject<BoardOrder> {

}
-(id)initWithBoard:(id<Board>)board;

@end
