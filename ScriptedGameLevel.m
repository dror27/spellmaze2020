#if SCRIPTING
//
//  ScriptedGameLevel.m
//  Board3
//
//  Created by Dror Kessler on 5/29/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ScriptedGameLevel.h"
#import "Folders.h"

//#define	DUMP

@interface ScriptedGameLevel (Privates)
-(void)loadFromProps:(NSDictionary*)props;
@end


@implementation ScriptedGameLevel
@synthesize interp = _interp;

-(void)dealloc
{
	[_interp release];
	
	[super dealloc];
}

-(id)initWithScriptPath:(NSString*)scriptPath andProps:(NSDictionary*)props
{
	if ( self = [super init] )
	{
		// create interpreter
		{
#ifdef DUMP
			double		startedAt = [[NSDate date] timeIntervalSince1970];
#endif
			self.interp = [[[JIMInterp alloc] init] autorelease];
#ifdef DUMP
			NSLog(@"initWithScriptPath: interp startup - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
		}
		
		// evaluate the script
		{
#ifdef DUMP
			double		startedAt = [[NSDate date] timeIntervalSince1970];
#endif
			[self.interp eval:[NSString stringWithContentsOfFile:scriptPath] withPath:scriptPath];
#ifdef DUMP
			NSLog(@"initWithScript: eval file - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
		}
		
		// init some fields
		[self loadFromProps:props];
		self.props = props;
		
		// eval the init proc
		{
#ifdef DUMP
			double		startedAt = [[NSDate date] timeIntervalSince1970];
#endif
			[self.interp eval:[NSString stringWithFormat:@"init %@", [JIMInterp objectAsCommand:self]]];
#ifdef DUMP
			NSLog(@"initWithScriptPath: proc init - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
		}
	}
	return self;
}

-(id)initWithScript:(NSString*)script andProps:(NSDictionary*)props
{
	if ( self = [super init] )
	{
		// create interpreter
		{
#ifdef DUMP
			double		startedAt = [[NSDate date] timeIntervalSince1970];
#endif
			self.interp = [[[JIMInterp alloc] init] autorelease];
#ifdef DUMP
			NSLog(@"initWithScript: interp startup - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
		}
		
		// evaluate the script
		{
#ifdef DUMP
			double		startedAt = [[NSDate date] timeIntervalSince1970];
#endif
			[self.interp eval:script];
#ifdef DUMP
			NSLog(@"initWithScript: eval script - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
		}
		
		// init some fields
		[self loadFromProps:props];
		
		// eval the init proc
		{
#ifdef DUMP
			double		startedAt = [[NSDate date] timeIntervalSince1970];
#endif
			[self.interp eval:[NSString stringWithFormat:@"init %@", [JIMInterp objectAsCommand:self]]];
#ifdef DUMP
			NSLog(@"initWithScript: proc init - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
		}
	}
	return self;
}

-(void)loadGame
{
	if ( state != INIT )
		return;
	
	[super loadGame];

	{
#ifdef DUMP
		double		startedAt = [[NSDate date] timeIntervalSince1970];		
#endif
		[self.interp eval:[NSString stringWithFormat:@"load %@", [JIMInterp objectAsCommand:self]]];	
#ifdef DUMP
		NSLog(@"loadGame: proc load - %g", [[NSDate date] timeIntervalSince1970] - startedAt); 
#endif
	}
	
	state = LOADED;
}

-(void)loadFromProps:(NSDictionary*)props
{
	self.uuid = [props objectForKey:@"uuid"];
	self.title = [props objectForKey:@"name"];
	self.shortDescription = [props objectForKey:@"description"];	
	
	self.helpSplashPanel = [SplashPanel splashPanelWithProps:[props objectForKey:@"help-splash"] 
													  forUUID:_uuid inDomain:DF_LEVELS withDelegate:self];
}

@end
#endif
