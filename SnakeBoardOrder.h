//
//  SnakeBoardOrder.h
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardOrder.h"

@class GridBoard;

@interface SnakeBoardOrder : NSObject<BoardOrder> {
	
	int		m_width;
}
-(id)initWithGridBoard:(GridBoard*)board;

@end
