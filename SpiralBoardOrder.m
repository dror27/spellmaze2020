//
//  SpiralBoardOrder.m
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "SpiralBoardOrder.h"
#import "GridBoard.h"


@implementation SpiralBoardOrder

-(id)initWithGridBoard:(GridBoard*)board
{
	if ( self = [super init] )
	{
		m_width = [board width];
		m_height = [board height];
		
		// fill index map
		m_indexMap = calloc(m_width * m_height, sizeof(int));
		for ( int order = 0 ; order < [board cellCount] ; order++ )
		{
			int		index = [self indexOfOrder:order];
			
			m_indexMap[index] = order;
		}
	}
	return self;
}

-(void)dealloc
{
	free(m_indexMap);
	
	[super dealloc];
}

-(int)orderOfIndex:(int)index
{
	return m_indexMap[index];
}

-(int)indexOfOrder:(int)order
{
	CGPoint		coor = [self coorOf:order withWidth:m_width andHeight:m_height];
	
	return coor.y * m_width + coor.x;
}

-(CGPoint)coorOf:(int)cellIndex withWidth:(int)width andHeight:(int)height
{
	CGPoint		coor = {0,0};
	
	if ( width <= 0 || height <= 0 )
	{
		// this is actually an error case
		return coor;
	}
	else if ( width == 1 || height == 1 )
	{
		// one cell board
		return coor;
	}
	
	else if ( cellIndex <= (width - 1) )
	{
		// top row
		coor.x = cellIndex;
		coor.y = 0;
		
		return coor;
	}
	else if ( cellIndex <= width + height - 2 )
	{
		// right columns
		coor.x = width - 1;
		coor.y = cellIndex - (width - 1);
		
		return coor;
	}
	else if ( cellIndex <= 2 * width + height - 3 )
	{
		// bottom row
		coor.x = (width - 1) - (cellIndex - (width + height - 2));
		coor.y = height - 1;
	}
	else if ( cellIndex <= 2 * width + 2 * height - 5 )
	{
		// left column
		coor.x = 0;
		coor.y = height - 1 - (cellIndex - (2 * width + height - 3));
	}
	else
	{
		int			innerCellIndex = cellIndex - (2 * width + 2 * height - 4);
		
		// inside inner spiral
		CGPoint		innerCoor = [self coorOf:innerCellIndex withWidth:width - 2 andHeight: height - 2];
		coor.x += innerCoor.x + 1;
		coor.y += innerCoor.y + 1;
		
		return coor;
	}
	
	// why here?
	return coor;
}

@end
