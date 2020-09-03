//
//  SystemUtils.m
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "SystemUtils.h"
#import "UserPrefs.h"
#import "RoleManager.h"



@implementation SystemUtils

+(NSString*)softwareVersion
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+(NSString*)softwareBuild
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+(NSDate*)expirationDate
{
	NSString*	text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SM_ExpirationDate"];
	if ( !text || ![text length] )
		return NULL;
	
	NSDateFormatter*	dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"dd/MM/yy"];
	
	return [dateFormatter dateFromString:text];
}

+(BOOL)hasExpired
{
	NSDate*		now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSDate*		expirationDate = [SystemUtils expirationDate];
	
	if ( [now compare:expirationDate] == NSOrderedDescending )
		return TRUE;
	else
		return FALSE;
}

+(BOOL)autorun
{
	return CHEAT_ON(CHEAT_AUTORUN);
}

+(float)autorunDelay
{
	return 0.2;
}

+(BOOL)autorunLevelLoop
{
	return CHEAT_ON(CHEAT_AUTORUN_LEVEL_LOOP);
}

+(BOOL)autorunGameLoop
{
	return CHEAT_ON(CHEAT_AUTORUN_GAME_LOOP);
}

+(BOOL)autorunAccumulateScore
{
	return CHEAT_ON(CHEAT_AUTORUN_ACCUMULATE_SCORE);
}

+(NSThread*)threadWithTarget:(id)target selector:(SEL)selector object:(id)object
{
	NSThread*	thread = [[[NSThread alloc] initWithTarget:target selector:selector object:object] autorelease];

	[thread setStackSize:THREAD_STACK_SIZE];
	[thread start];
	
	return thread;
}

@end

