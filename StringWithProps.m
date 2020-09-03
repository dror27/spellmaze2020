//
//  StringWithProps.m
//  SpellMaze
//
//  Created by Dror Kessler on 12/13/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "StringWithProps.h"


@implementation StringWithProps
@synthesize props = _props;

-(void)dealloc
{
	[_props release];
	
	[super dealloc];
}

@end
