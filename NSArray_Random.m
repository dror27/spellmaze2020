//
//  NSArray_Random.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/23/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "NSArray_Random.h"

//#define	DEBUG_BYPASS_RANDOM


@implementation NSArray(Random)

-(NSObject*)objectAtRandomIndex
{
	int		count = [self count];
	
#ifdef	DEBUG_BYPASS_RANDOM
	if ( count )
		return [self objectAtIndex:0];
#else
	if ( count == 1 )
		return [self objectAtIndex:0];
	else if ( count )
		return [self objectAtIndex:(rand() % count)];
#endif
	else
		return nil;
}

@end
