//
//  RandomBoardOrder.m
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "RandomBoardOrder.h"
#import "GridBoard.h"


@implementation RandomBoardOrder

-(id)initWithGridBoard:(GridBoard*)board
{
	if ( self = [super init] )
	{
		m_width = [board width];
		m_height = [board height];

		// allocate maps
		m_indexMap = calloc(m_width * m_height, sizeof(int));
		m_xMap = calloc(m_width * m_height, sizeof(int));
		m_yMap = calloc(m_width * m_height, sizeof(int));

		// fill index map
		int		size = m_width * m_height;
		for ( int index = 0 ; index < size ; index++ )
			m_indexMap[index] = index;
		
		// scamble index map
		for ( int n = 0 ; n < size * 4 ; n++ )
		{
			int		i1 = rand() % size;
			int		i2 = rand() % size;
			
			int		tmp = m_indexMap[i1];
			m_indexMap[i1] = m_indexMap[i2];
			m_indexMap[i2] = tmp;
		}
		
		// build x/y maps
		for ( int index = 0 ; index < size ; index++ )
		{
			int		cellIndex = m_indexMap[index];
			int		x = cellIndex % m_width;
			int		y = cellIndex / m_width;
			
			m_xMap[index] = x;
			m_yMap[index] = y;
		}
		
		
	}
	return self;
}

-(void)dealloc
{
	free(m_indexMap);
	free(m_xMap);
	free(m_yMap);
	
	[super dealloc];
}

-(int)orderOfIndex:(int)index
{
	return m_indexMap[index];
}

-(int)indexOfOrder:(int)order;
{
	int		x  = m_xMap[order];
	int		y = m_yMap[order];
	
	return y * m_width + x;
}

@end
