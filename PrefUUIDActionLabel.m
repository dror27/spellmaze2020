//
//  PrefUUIDActionLabel.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefUUIDActionLabel.h"


@implementation PrefUUIDActionLabel
@synthesize uuid = _uuid;
@synthesize param = _param;

-(void)dealloc
{
	[_uuid release];
	[_param release];
	
	[super dealloc];
}

@end
