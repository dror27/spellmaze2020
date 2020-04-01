//
//  SimpleBoardOrder.m
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "SimpleBoardOrder.h"
#import "GridBoard.h"

@implementation SimpleBoardOrder

-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super init] )
	{
	}
	return self;
}

-(int)indexOfOrder:(int)order
{
	return order;
}

-(int)orderOfIndex:(int)index
{
	return index;
}



@end
