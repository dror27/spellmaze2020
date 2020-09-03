//
//  ImageWithUUID.m
//  SpellMaze
//
//  Created by Dror Kessler on 12/10/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "ImageWithUUID.h"
#import "UUIDUtils.h"


@implementation ImageWithUUID
@synthesize uuid = _uuid;
@synthesize lastTimeUsed;
@synthesize key = _key;


-(void)dealloc
{
	[_uuid release];
	[_key release];
	
	[super dealloc];
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"%@ %ld %@", _uuid, lastTimeUsed, _key];
}

@end
