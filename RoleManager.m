//
//  RoleManager.m
//  Board3
//
//  Created by Dror Kessler on 9/2/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoleManager.h"
#import "UserPrefs.h"
#import "ScoresDatabase.h"

extern time_t appStartedAt;
extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"RoleManager_singleton"


@implementation RoleManager
@synthesize cheats = _cheats;

+(RoleManager*)singleton
{
	@synchronized ([RoleManager class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[RoleManager alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(id)init
{
	if ( self = [super init] )
	{
		// register for changes
		[UserPrefs addKeyDelegate:self forKey:PK_IDENTITY_NICK];
		
		self.cheats = [NSMutableDictionary dictionary];
		
		// get process going
		[self filteredNickname];
	}
	return self;
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	// refresh settings
	[self filteredNickname];
}

-(NSString*)transformString:(NSString*)s
{
	return [self filteredNicknameFromNick:s];
}

-(NSString*)filteredNickname
{
	return [self filteredNicknameFromNick:[UserPrefs getString:PK_IDENTITY_NICK withDefault:[[UIDevice currentDevice] name]]];
}

-(NSString*)filteredNicknameFromNick:(NSString*)name
{
	if ( !name )
		return NULL;
	
	// split on code seperators
	NSArray*	codes = [name componentsSeparatedByString:@"/"];
	name = [codes objectAtIndex:0];
	
	// decypher codes
	[_cheats removeAllObjects];
	if ( [codes count] > 1 )
	{
		for ( NSString* code in [codes subarrayWithRange:NSMakeRange(1, [codes count] - 1)] )
		{
			NSString*		reportType = [RT_CHEAT_XXX stringByAppendingString:code];
			
			if ( ![globalData hasKey:reportType] )
			{
				[[ScoresDatabase singleton] reportLevelEvent:NULL withType:reportType withTimeDelta:time(NULL) - appStartedAt];
				[globalData setObject:[NSNumber numberWithBool:TRUE] forKey:reportType];
			}
			
			[_cheats setObject:[NSNumber numberWithBool:TRUE] forKey:code];
		}
	}	
	
	return name;
}



@end
