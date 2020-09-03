#if SCRIPTING
//
//  ScriptPullHandler.m
//  Board3
//
//  Created by Dror Kessler on 9/26/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "ScriptPullHandler.h"
#import "JIMInterp.h"


@implementation ScriptPullHandler

-(NSArray*)push
{
	// extract script
	NSString*		script = [_pullRequest objectForKey:@"script"];
	if ( !script )
		return NULL;
	
	// create an interpreter
	JIMInterp*		interp = [[[JIMInterp alloc] init] autorelease];

	id				result = NULL;
	@try
	{
		// evaluate the script
		[interp eval:script];
		
		// evalue the push proc with the pullRequest as its parameter
		result = [interp eval:[NSString stringWithFormat:@"push %@", [JIMInterp objectAsCommand:_pullRequest]]];
	}
	@catch (NSException* e)
	{
		NSLog(@"GameManager: ScriptPullHandler: %@", e);
	}
	if ( !result )
		return NULL;
	
	// convert result into an NSData
	NSData*			data;
	if ( [result isKindOfClass:[NSData class]] )
		data = result;
	else
	{
		// build a dictionary around it?
		NSMutableDictionary*		dict;
		
		if ( [result isKindOfClass:[NSDictionary class]] )
			dict = result;
		else
			dict = [NSMutableDictionary dictionaryWithObject:result forKey:@"result"];

			
		NSString*					errorString;
		data = [NSPropertyListSerialization dataFromPropertyList:dict 
															format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
		if ( !data || errorString )
		{
			NSLog(@"ERROR - %@", errorString);
			return NULL;
		}
	}
	
	// let base do the hard (sending/recieving) work ...
	return [self doPush:data withUrlSuffix:NULL];
}


@end
#endif
