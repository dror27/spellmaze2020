//
//  UserPrefs.m
//  Board3
//
//  Created by Dror Kessler on 7/14/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "UserPrefs.h"
#import "RoleManager.h"
#import "UUIDPrefs.h"
#import "NSDictionary_TypedAccess.h"
#import "GameLevel.h"
#import "UUIDUtils.h"

//#define	DUMP_IDENTITIES

static NSMutableDictionary*	userPrefs_delegates;

static BOOL isIdentityKey(NSString* s)
{
	if ( !s || ![s length] )
		return FALSE;
	
	unichar ch = [s characterAtIndex:0];
	
	if ( ch == '_' )
		return FALSE;
	
	if ( toupper(ch) == ch )
		return FALSE;
	
	return TRUE;
}

@interface UserPrefs (Privates)
+(void)synchronizeDelayed:(BOOL)delayed;
+(void)synchronizeAndFireForKey:(NSString*)key;
+(void)synchronizeAndFireForKeys:(NSArray*)keys;
@end

static NSMutableSet*	UserPrefs_pendingKeys = NULL;

@implementation UserPrefs

+(void)init
{
	userPrefs_delegates = [[NSMutableDictionary alloc] init];
}

+(BOOL)hasKey:(NSString*)key
{
	NSDictionary*	dict;
	
	if ( !key )
		return FALSE;

	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];

	if ( [ud objectForKey:key] )
		return TRUE;
	else if ( dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key] )
		return [dict hasKey:key];
	else
		return FALSE;
}

+(NSString*)getString:(NSString*)key withDefault:(NSString*)value
{
	if ( !key )
		return value;
		
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	NSString*		result = [ud stringForKey:key];
	if ( result )
		return result;
	
	NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
	if ( dict )
		return [dict stringForKey:key withDefaultValue:value];
	
	return value;
}

+(void)setString:(NSString*)key withValue:(NSString*)value
{
	[UserPrefs setString:key withValue:value force:FALSE];
}

+(void)setString:(NSString*)key withValue:(NSString*)value force:(BOOL)force
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( !force )
	{
		// block redundent sets
		NSString*			currentValue = [ud objectForKey:key];
		if ( currentValue && [currentValue isKindOfClass:[NSString class]] && [currentValue isEqualToString:value] )
			return;
		if ( !currentValue && !value )
			return;
		
		// HACK
		if ( !currentValue && ![value length] )
			return;
	}
	
	[ud setObject:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(int)getInteger:(NSString*)key withDefault:(int)value
{	
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	NSNumber*		num;
	
	if ( num = [ud objectForKey:key] )
	{
		return [num intValue];
	}
	else
	{
		NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
		if ( dict )
			return [dict integerForKey:key withDefaultValue:value];

		return value;
	}
}

+(void)setInteger:(NSString*)key withValue:(int)value
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	// block redundent sets
	NSNumber*			currentValue = [ud objectForKey:key];
	if ( currentValue && [currentValue isKindOfClass:[NSNumber class]] && [currentValue intValue] == value )
		return;

	[ud setInteger:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(float)getFloat:(NSString*)key withDefault:(float)value
{	
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud objectForKey:key] )
		return [ud floatForKey:key];
	else
	{
		NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
		if ( dict )
			return [dict floatForKey:key withDefaultValue:value];
		
		return value;
	}
}

+(void)setFloat:(NSString*)key withValue:(float)value
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	// block redundent sets
	NSNumber*			currentValue = [ud objectForKey:key];
	if ( currentValue && [currentValue isKindOfClass:[NSNumber class]] && [currentValue floatValue] == value )
		return;

	[ud setFloat:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(BOOL)getBoolean:(NSString*)key withDefault:(BOOL)value
{	
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud objectForKey:key] )
		return [ud boolForKey:key];
	else
	{
		NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
		if ( dict )
			return [dict booleanForKey:key withDefaultValue:value];
		
		return value;
	}
}

+(void)setBoolean:(NSString*)key withValue:(BOOL)value
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	// block redundent sets
	NSNumber*			currentValue = [ud objectForKey:key];
	if ( currentValue && [currentValue isKindOfClass:[NSNumber class]] && [currentValue boolValue] == value )
		return;

	[ud setBool:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(NSArray*)getArray:(NSString*)key withDefault:(NSArray*)value
{	
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud arrayForKey:key] )
		return [ud arrayForKey:key];
	else
	{
		NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
		if ( dict )
			return [dict arrayForKey:key withDefaultValue:value];
		
		return value;
	}
}

+(void)setArray:(NSString*)key withValue:(NSArray*)value
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	[ud setObject:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(NSDictionary*)getDictionary:(NSString*)key withDefault:(NSDictionary*)value
{	
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud dictionaryForKey:key] )
		return [ud dictionaryForKey:key];
	else
	{
		NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
		if ( dict )
			return [dict dictionaryForKey:key withDefaultValue:value];
		
		return value;
	}
}

+(void)setDictionary:(NSString*)key withValue:(NSDictionary*)value
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	[ud setObject:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(id)getObject:(NSString*)key withDefault:(id)value
{	
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud objectForKey:key] )
		return [ud objectForKey:key];
	else
	{
		NSDictionary*	dict = [UUIDPrefs findLoadedUUIDPrefsDataForKey:&key];
		if ( dict )
			return [dict objectForKey:key withDefaultValue:value];
		
		return value;
	}
}

+(void)setObject:(NSString*)key withValue:(id)value
{
	if ( !key )
		return;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	[ud setObject:value forKey:key];
	
	[UserPrefs synchronizeAndFireForKey:key];
}

+(BOOL)levelEnabled:(NSString*)uuid
{
	if ( CHEAT_ON(CHEAT_ENABLE_ALL_LEVELS) )
		return TRUE;
	
	NSString*		key = [NSString stringWithFormat:@"%@.%@", PK_LEVEL_ENABLED, uuid];
	
	return [[UserPrefs getString:key withDefault:@"0"] isEqualToString:@"1"];
}

+(void)setLevelEnabled:(NSString*)uuid enabled:(BOOL)value
{
	NSString*		key = [NSString stringWithFormat:@"%@.%@", PK_LEVEL_ENABLED, uuid];
	
	[UserPrefs setString:key withValue:(value ? @"1" : @"0")];
}

+(BOOL)levelPassed:(GameLevel*)level
{
	NSString*		key = [NSString stringWithFormat:@"%@.%@:%@", PK_LEVEL_PASSED, [level uuid], [[[level seq] language] uuid]];
	
	return [[UserPrefs getString:key withDefault:@"0"] isEqualToString:@"1"];
}

+(void)setLevelPassed:(GameLevel*)level passed:(BOOL)value
{
	NSString*		key = [NSString stringWithFormat:@"%@.%@:%@", PK_LEVEL_PASSED, [level uuid], [[[level seq] language] uuid]];
	
	[UserPrefs setString:key withValue:(value ? @"1" : @"0")];
}

+(BOOL)levelExhausted:(GameLevel*)level
{
	NSString*		key = [NSString stringWithFormat:@"%@.%@:%@:Exhausted", PK_LEVEL_PASSED, [level uuid], [[[level seq] language] uuid]];
	
	return [[UserPrefs getString:key withDefault:@"0"] isEqualToString:@"1"];
}

+(void)setLevelExhausted:(GameLevel*)level passed:(BOOL)value
{
	NSString*		key = [NSString stringWithFormat:@"%@.%@:%@:Exhausted", PK_LEVEL_PASSED, [level uuid], [[[level seq] language] uuid]];
	
	[UserPrefs setString:key withValue:(value ? @"1" : @"0")];
}

+(NSString*)userIdentity
{
	NSString*		uuid = [UserPrefs getString:PK_IDENTITY_UUID withDefault:NULL];
	
	if ( uuid == NULL )
	{
		CFUUIDRef	uuidRef = CFUUIDCreate(NULL);
		CFStringRef	strRef = CFUUIDCreateString(NULL, uuidRef);
	
		uuid = [NSString stringWithFormat:@"%@", strRef];
		
		[UserPrefs setString:PK_IDENTITY_UUID withValue:uuid];
	}
	
	return uuid;
}

+(NSString*)userNick
{
	return [[RoleManager singleton] filteredNickname];
}

+(NSString*)key:(NSString*)key forUuid:(NSString*)uuid
{
	return [NSString stringWithFormat:@"%@_%@", uuid, key];
}

+(void)addKeyDelegate:(id<UserPrefsDelegate>)delegate forKey:(NSString*)key
{
	//NSLog(@"addKeyDelegate: %@ (%p) for %@", delegate, delegate, key);
	@synchronized (userPrefs_delegates) 
	{
		NSMutableSet*	delegates = [userPrefs_delegates objectForKey:key];
		
		if ( delegates == NULL )
		{
			delegates = [[[NSMutableSet alloc] init] autorelease];
			[userPrefs_delegates setObject:delegates forKey:key];
		}
		
		if ( ![delegates containsObject:delegate] )
		{
			[delegates addObject:delegate];

			// make delegate reference a weak one!
			[delegate autorelease];
		}
	}
}

+(void)removeKeyDelegate:(id<UserPrefsDelegate>)delegate forKey:(NSString*)key
{
	@synchronized (userPrefs_delegates) 
	{
		NSMutableSet*	delegates = [userPrefs_delegates objectForKey:key];
		
		if ( delegates != NULL )
		{
			if ( [delegates containsObject:delegate] )
			{
				// compensate for the 'release' executed by the addObject: selector. this is a week reference array!
				[delegate retain];

				[delegates removeObject:delegate];
			}
		}
	}
}



+(void)fireDelegatesForKey:(NSString*)key
{
	@synchronized (userPrefs_delegates) 
	{
		NSMutableSet*	delegates = [userPrefs_delegates objectForKey:key];
		
		if ( delegates != NULL )
			for ( id<UserPrefsDelegate> delegate in delegates )
				[delegate userPrefsKeyChanged:key];
	}
}

+(void)removeKey:(NSString*)key
{
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud objectForKey:key] )
	{
		[ud removeObjectForKey:key];
		
		[UserPrefs synchronizeAndFireForKey:key];
	}
}

+(void)removeByPrefix:(NSString*)prefix
{
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	NSMutableSet*	removedKeys = [[[NSMutableSet alloc] init] autorelease];
	
	for ( NSString* key in [[ud dictionaryRepresentation] allKeys] )
	{
		if ( !prefix || [key hasPrefix:prefix] )
		{
			[removedKeys addObject:key];
			[ud removeObjectForKey:key];
		}
	}
	
	[UserPrefs synchronizeAndFireForKeys:[removedKeys allObjects]];
}

+(void)removeAll
{
	[UserPrefs removeByPrefix:NULL];
}

+(NSArray*)listKeysWithPrefix:(NSString*)prefix
{
	NSUserDefaults*		ud = [NSUserDefaults standardUserDefaults];
	NSMutableArray*		keys = [[NSMutableArray alloc] init];
	NSDictionary*		dict = [ud dictionaryRepresentation];
	
	for ( NSString* key in [dict allKeys] )
		if ( !prefix || ![prefix length] || [key hasPrefix:prefix] )
			[keys addObject:key];
	
	return keys;
}

+(void)copyKey:(NSString*)key toKey:(NSString*)toKey
{
	NSUserDefaults*		ud = [NSUserDefaults standardUserDefaults];
	
	NSObject*			value = [ud objectForKey:key];
	if ( value )
	{
		value = [value copy];
		
		[ud setObject:value forKey:toKey];
		
		[UserPrefs synchronizeAndFireForKey:toKey];
	}
}

// HACK HACK HACK
+(NSString*)getExplicitString:(NSString*)key withDefault:(NSString*)value
{
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	NSString*		result = [ud stringForKey:key];
	if ( result )
		return result;
	else
		return value;
	
}

+(BOOL)getExplicitBoolean:(NSString*)key withDefault:(BOOL)value
{
	if ( !key )
		return value;
	
	NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
	
	if ( [ud objectForKey:key] )
		return [ud boolForKey:key];
	else
		return value;
}

+(NSArray*)allIdentities
{
	NSMutableArray*	all = [NSMutableArray arrayWithArray:[UserPrefs getArray:PK_IDENTITIES withDefault:[NSArray array]]];
	NSString*		current = [UserPrefs userIdentity];
	
	if ( ![all containsObject:current] )
		[all addObject:current];
	
	return all;
}

+(NSString*)identityNick:(NSString*)uuid
{
	NSString*		current = [UserPrefs userIdentity];

	if ( [uuid isEqualToString:current] )
		return [UserPrefs userNick];
	else
	{
		NSString*	key = [UserPrefs key:PK_IDENTITY_NICK forIdentity:uuid];
		NSString*	nick = [UserPrefs getString:key withDefault:@""];
		
		return [[RoleManager singleton] filteredNicknameFromNick:nick];
	}
}

+(NSString*)createIdentity:(NSString*)nick
{
#ifdef	DUMP_IDENTITIES
	[UserPrefs logIdentities:@"createIdentitiy ENTER"];
#endif
	
	NSMutableArray*		all = [NSMutableArray arrayWithArray:[UserPrefs allIdentities]];
	NSString*			uuid = [UUIDUtils createUUID];
	
	[all addObject:uuid];
	[UserPrefs setArray:PK_IDENTITIES withValue:all];
	
	[UserPrefs setString:[UserPrefs key:PK_IDENTITY_UUID forIdentity:uuid] withValue:uuid];
	[UserPrefs setString:[UserPrefs key:PK_IDENTITY_NICK forIdentity:uuid] withValue:nick];
	
#ifdef	DUMP_IDENTITIES
	[UserPrefs logIdentities:[NSString stringWithFormat:@"createIdentitiy RETURN %@", uuid]];
#endif
	return uuid;
}

+(void)removeIdentity:(NSString*)uuid
{
#ifdef	DUMP_IDENTITIES
	[UserPrefs logIdentities:[NSString stringWithFormat:@"removeIdentity ENTER %@", uuid]];
#endif
	// can't remove if there is only one
	NSMutableArray*		all = [NSMutableArray arrayWithArray:[UserPrefs allIdentities]];
	if ( [all count] <= 1 )
		return;

	// before removing current, switch to another one
	NSString*		current = [UserPrefs userIdentity];
	if ( [uuid isEqualToString:current] )
	{
		NSString*	newCurrent = NULL;
		
		for ( NSString* u in all )
			if ( ![u isEqualToString:current] )
			{
				newCurrent = u;
				break;
			}
		if ( !newCurrent )
			return;
		[UserPrefs switchIdentity:newCurrent];
		all = [NSMutableArray arrayWithArray:[UserPrefs allIdentities]];
	}
	
	// remove from all
	[all removeObject:uuid];
	[UserPrefs setArray:PK_IDENTITIES withValue:all];

	// remove all identity keys
	[UserPrefs removeByPrefix:[UserPrefs key:@"" forIdentity:uuid]];

#ifdef	DUMP_IDENTITIES
	[UserPrefs logIdentities:@"removeIdentity RETURN"];
#endif	
}

+(void)switchIdentity:(NSString*)uuid
{
#ifdef	DUMP_IDENTITIES
	[UserPrefs logIdentities:[NSString stringWithFormat:@"switchIdentity ENTER %@", uuid]];
#endif
	// already on current?
	NSString*		current = [UserPrefs userIdentity];
	if ( [uuid isEqualToString:current] )
		return;
	
	// must be in all
	if ( ![[UserPrefs allIdentities] containsObject:uuid] )
		return;
	
	@synchronized ([UserPrefs class])
	{
		[UserPrefs synchronizeDelayed:TRUE];
		
		// backup all current identity related keys into the identity specific keys
		[UserPrefs removeByPrefix:[UserPrefs key:@"" forIdentity:current]];
		for ( NSString* key in [UserPrefs listKeysWithPrefix:@""] )
			if ( isIdentityKey(key) )
			{
				id		value = [UserPrefs getObject:key withDefault:NULL];
				
				[UserPrefs setObject:[UserPrefs key:key forIdentity:current] withValue:value];
			}
		
		// restore identity specific keys
		for ( NSString* key in [UserPrefs listKeysWithPrefix:@""] )
			if ( isIdentityKey(key) )
				[UserPrefs removeKey:key];
		NSString*	keyPrefix = [UserPrefs key:@"" forIdentity:uuid];
		int			keyPrefixLengh = [keyPrefix length];
		for ( NSString* key in [UserPrefs listKeysWithPrefix:keyPrefix] )
		{
			NSString*	ikey = [key substringFromIndex:keyPrefixLengh];
			
			id			value = [UserPrefs getObject:key withDefault:NULL];
			
			[UserPrefs setObject:ikey withValue:value];
		}
		
		[UserPrefs synchronizeDelayed:FALSE];
	}

#ifdef	DUMP_IDENTITIES
	[UserPrefs logIdentities:@"switchIdentity RETURN"];
#endif		
}

+(NSString*)key:(NSString*)key forIdentity:(NSString*)uuid
{
	return [NSString stringWithFormat:PK_IDENTITIY_KEY, uuid, key];
}

+(void)logIdentities:(NSString*)message
{
	NSString*		current = [UserPrefs userIdentity];

	NSLog(@"[UserPrefs] : %@", message);
	for ( NSString* uuid in [UserPrefs allIdentities] )
		NSLog(@"[UserPrefs]   %@ %@ [%@]", 
			  [uuid isEqualToString:current] ? @"*" : @"-",
			  uuid,
			  [UserPrefs identityNick:uuid]);
}

+(void)synchronizeDelayed:(BOOL)delayed
{
	// must be called inside a syncronization block!!!
	if ( delayed )
		UserPrefs_pendingKeys = [[NSMutableSet set] retain];
	else if ( UserPrefs_pendingKeys )
	{
		NSUserDefaults*		ud = [NSUserDefaults standardUserDefaults];
		NSSet*				keys = [NSSet setWithSet:UserPrefs_pendingKeys];
		
		[UserPrefs_pendingKeys autorelease];
		UserPrefs_pendingKeys = NULL;
		[ud synchronize];
		for ( NSString* key in keys )
			[UserPrefs fireDelegatesForKey:key];
		
	}
}

+(void)synchronizeAndFireForKey:(NSString*)key
{
	[UserPrefs synchronizeAndFireForKeys:[NSArray arrayWithObject:key]];
}

+(void)synchronizeAndFireForKeys:(NSArray*)keys
{
	if ( UserPrefs_pendingKeys )
		[UserPrefs_pendingKeys addObjectsFromArray:keys];
	else
	{
		NSUserDefaults*		ud = [NSUserDefaults standardUserDefaults];
		
		[ud synchronize];
		for ( NSString* key in keys )
			[UserPrefs fireDelegatesForKey:key];
	}
}


@end
