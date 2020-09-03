//
//  ProgrammableGameLevelFactory.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/20/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "ParametricGameLevelFactory.h"
#import "ParametricGameLevel.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"

@implementation ParametricGameLevelFactory
@synthesize props = _props;
@synthesize uuid = _uuid;
@synthesize seq = _seq;

-(id)initWithUUID:(NSString*)uuid
{
	NSDictionary*				props = [Folders findUUIDProps:NULL forDomain:DF_LEVELS withUUID:uuid];
	
	self = [self initWithProps:props];
	
	self.uuid = uuid;
	
	return self;
}

-(id)initWithProps:(NSDictionary*)props
{
	self.props = props;
	
	if ( !self.uuid && [props objectForKey:@"uuid"] )
		self.uuid = [props objectForKey:@"uuid"];
	
	return self;
}


-(void)dealloc
{
	[_uuid release];
	[_props release];
	
	[super dealloc];
}

-(GameLevel*)createGameLevel
{
	GameLevel*	level = [[[ParametricGameLevel alloc] initWithProps:_props] autorelease];
	
	level.props = self.props;
	level.seq = self.seq;
	
	return level;
}

@end


