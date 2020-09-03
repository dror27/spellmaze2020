//
//  ListBoardOrder.h
//  Board3
//
//  Created by Dror Kessler on 8/25/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardOrder.h"

@class GridBoard;
@interface ListBoardOrder : NSObject<BoardOrder> {

	int*	index2order;
	int*	order2index;
	int		cellCount;
}
-(id)initWithGridBoard:(GridBoard*)board andList:(NSString*)list;
@end
