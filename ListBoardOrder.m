//
//  ListBoardOrder.m
//  Board3
//
//  Created by Dror Kessler on 8/25/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ListBoardOrder.h"
#import "GridBoard.h"


@implementation ListBoardOrder

-(id)initWithGridBoard:(GridBoard*)board andList:(NSString*)list
{
	if ( self = [super init] )
	{
		if ( list )
		{
			cellCount = [board cellCount];
			index2order = calloc(cellCount, sizeof(int));
			order2index = calloc(cellCount, sizeof(int));
			
			int		index = 0;
			for ( NSString* s in [list componentsSeparatedByString:@","] )
			{
				if ( index < cellCount )
				{
					int		order = atoi([s UTF8String]);
					if ( order < cellCount )
					{
						order2index[index] = order;
						index2order[order] = index;
					}
				}
				index++;
			}
		}
	}
	return self;
}

-(void)dealloc
{
	if ( index2order )
		free(index2order);
	if ( order2index )
		free(order2index);
	
	[super dealloc];
}

-(int)indexOfOrder:(int)order
{
	if ( order2index && order < cellCount )
		return order2index[order];
	else
		return order;
}

-(int)orderOfIndex:(int)index
{
	if ( index2order && index < cellCount )
		return index2order[index];
	else
		return index;
}

@end
