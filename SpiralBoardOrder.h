//
//  SpiralBoardOrder.h
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BoardOrder.h"

@class GridBoard;

@interface SpiralBoardOrder : NSObject<BoardOrder> {
	
	int		m_width;
	int		m_height;
	int*	m_indexMap;
}
-(id)initWithGridBoard:(GridBoard*)board;

// privates
-(CGPoint)coorOf:(int)cellIndex withWidth:(int)width andHeight:(int)height;

@end
