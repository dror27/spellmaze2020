//
//  UUIDPrefs.m
//  Board3
//
//  Created by Dror Kessler on 9/6/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "UUIDPrefs.h"
#import "GameManager.h"
#import "GameLevelSequence.h"
#import "HasProps.h"


@implementation UUIDPrefs

+(NSArray*)splitUUIDKey:(NSString*)key
{
	if ( !key || [key length] < 38 || [key characterAtIndex:36] != '/' )
		return NULL;
	
	NSString*		uuid = [key substringToIndex:36];
	NSString*		tail = [key substringFromIndex:37];
	
	return [NSArray arrayWithObjects:uuid, tail, NULL];
}

+(NSDictionary*)findLoadedUUIDProps:(NSString*)uuid
{
	id<HasUUID>		hasUUID = NULL;
	
	// lookup in the current game
	hasUUID = [[GameManager currentGameLevelSequence] findHasUUID:uuid];
	
	// available?
	if ( hasUUID && [hasUUID respondsToSelector:@selector(props)] )
		return [((id<HasProps>)hasUUID) props];
	else
		return NULL;
}

+(NSDictionary*)findLoadedUUIDPrefsData:(NSString*)uuid
{
	NSDictionary*		dict = [UUIDPrefs findLoadedUUIDProps:uuid];
	
	return dict ? [dict objectForKey:@"prefs-data"] : NULL;
}

+(NSDictionary*)findLoadedUUIDPrefsDataForKey:(NSString**)key
{
	NSArray*		comps = [UUIDPrefs splitUUIDKey:*key];
	if ( !comps )
		return NULL;
	
	NSString*		uuid = [comps objectAtIndex:0];
	NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsData:uuid];
	if ( !dict )
		return NULL;
	
	*key = [comps objectAtIndex:1];
	return dict;
}

@end
