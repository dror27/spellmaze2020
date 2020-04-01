//
//  PrefFilePage.m
//  Board3
//
//  Created by Dror Kessler on 8/10/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefFilePage.h"


@implementation PrefFilePage
@synthesize path = _path;

-(id)initWithFile:(NSString*)path
{
	if ( self = [super init] )
	{
		self.path = path;
	}
	return self;
}

-(void)dealloc
{
	[_path release];
	
	[super dealloc];
}

-(NSString*)title
{
	NSString*	title = [super title];
	
	if ( !title )
	{
		title = [self.path lastPathComponent];
		
		[super setTitle:title];
	}
	
	return title;
}

-(NSArray*)sections
{
	return [NSArray array];
}

@end
