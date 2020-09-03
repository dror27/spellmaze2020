//
//  SnakeBoardOrder.m
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//
// Snake - even rows go up, odd rows go down

#import "SnakeBoardOrder.h"
#import "GridBoard.h"

@implementation SnakeBoardOrder

-(id)initWithGridBoard:(GridBoard*)board
{
	if ( self = [super init] )
	{
		m_width = [board width];
	}
	return self;
}

-(int)orderOfIndex:(int)index
{
	int			x = index % m_width;
	int			y = index / m_width;
	BOOL		even = (y % 2) == 0;
	
	return y * m_width + (even ? x : (m_width - 1 - x));	
}

-(int)indexOfOrder:(int)order
{
	int		x = order % m_width;
	int		y = order / m_width;
	
	BOOL		even = (y % 2) == 0;
	if ( !even )
		x = m_width - 1 - x;
	
	return y * m_width + x;
}


@end
