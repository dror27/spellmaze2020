//
//  PullManager.m
//  Board3
//
//  Created by Dror Kessler on 9/24/09.
//  Copyright 2020 Dror Kessler. All rights reserved.
//

#import "PullManager.h"
#import "ReportLogPullHandler.h"
#import "ScriptPullHandler.h"


@implementation PullManager

+(id<PullHandler>)pullHandlerForRequest:(NSDictionary*)pullRequest
{
	// create based on type
	NSString*	type = [pullRequest objectForKey:@"type"];
	if ( !type )
		return NULL;
	else if ( [type isEqualToString:@"report-log"] )
		return [[[ReportLogPullHandler alloc] initWithPullRequest:pullRequest] autorelease];
#if SCRIPTING
	else if ( [type isEqualToString:@"script"] )
		return [[[ScriptPullHandler alloc] initWithPullRequest:pullRequest] autorelease];
#endif
	else
		return NULL;
}

@end
