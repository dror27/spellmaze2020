//
//  SingleProbabilityURS.m
//  Board3
//
//  Created by Dror Kessler on 10/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SingleProbabilityURS.h"

//#define	DUMP

@implementation SingleProbabilityURS
@synthesize probability = p;

-(id)initWithProbability:(double)probability
{
	if ( self = [super init] )
	{
		p = probability;
		n = k = 0;
	}
	return self;
}

-(int)next
{
	// calculate adaptive probability
	double		pa = p * (n + 1) - k;
	
	// generate value
	int			v;
	if ( pa <= 0 )
		v = 0;
	else if ( pa >= 1 )
		v = 1;
	else
		v = (rand() <= (pa * RAND_MAX)) ? 1 : 0;
	
	// update counts;
	n++;
	k += v;
	
#ifdef	DUMP
	NSLog(@"[SingleProbabilityURS] p=%f, pa=%f, k/n=%f, v=%d", p, pa, (double)k/n, v);
#endif
	
	return v;
}

@end
