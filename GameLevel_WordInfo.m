//
//  WordInfo.m
//  Board3
//
//  Created by Dror Kessler on 7/27/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GameLevel_WordInfo.h"


@implementation GameLevel_WordInfo

@synthesize count;
@synthesize type;
@synthesize scoreContrib;
@synthesize scoreContribFancy;

-(id)init
{
	if ( self = [super init] )
	{
		count = 0;
		scoreContrib = 0;
		scoreContribFancy = FALSE;
	}
	
	return self;
}

@end
