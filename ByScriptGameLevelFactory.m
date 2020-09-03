#if SCRIPTING
//
//  ByScriptGameLevelFactory.m
//  Board3
//
//  Created by Dror Kessler on 5/29/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ByScriptGameLevelFactory.h"
#import "ScriptedGameLevel.h"


@implementation ByScriptGameLevelFactory
@synthesize props = _props;
@synthesize script = _script;
@synthesize scriptPath = _scriptPath;
@synthesize uuid = _uuid;
@synthesize seq = _seq;

-(void)dealloc
{
	[_uuid release];
	[_props release];
	[_script release];
	[_scriptPath release];
	
	[super dealloc];
}

-(id)initWithScriptPath:(NSString*)scriptPath
{
	if ( self = [super init] )
	{
		self.scriptPath = scriptPath;
	}
	return self;
}

-(id)initWithScript:(NSString*)script
{
	if ( self = [super init] )
	{
		self.script = script;
	}
	return self;
}


-(GameLevel*)createGameLevel
{
	GameLevel*	level;
	
	if ( _scriptPath )
		level = [[[ScriptedGameLevel alloc] initWithScriptPath:_scriptPath andProps:self.props] autorelease];
	else if ( _script )
		level = [[[ScriptedGameLevel alloc] initWithScript:_script andProps:self.props] autorelease];
	else
		return NULL;
	
	level.props = self.props;
	level.seq = self.seq;
	
	return level;
}

@end
#endif
