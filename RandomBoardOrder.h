//
//  RandomBoardOrder.h
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardOrder.h"

@class GridBoard;

@interface RandomBoardOrder : NSObject<BoardOrder> {
	
	int		m_width;
	int		m_height;
	
	int*	m_indexMap;
	int*	m_xMap;
	int*	m_yMap;
	
}
-(id)initWithGridBoard:(GridBoard*)board;

@end
