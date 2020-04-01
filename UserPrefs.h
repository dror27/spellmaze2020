//
//  UserPrefs.h
//  Board3
//
//  Created by Dror Kessler on 7/14/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#define		PK_SCORE			@"score"
#define		PK_LEVEL_ENABLED	@"level-enabled"
#define		PK_LEVEL_PASSED		@"level-passed"
#define		PK_IDENTITY_UUID	@"identity-uuid"
#define		PK_IDENTITY_NICK	@"pref_scoring_nickname"
#define		PK_SEP_RESPONSE		@"sep-response-0"
#define		PK_NSEP_RESPONSE	@"nsep-response-0"

#define		PK_LAST_LEVEL		@"last-level"

#define		PK_GAME_SPEED		@"pref_game_speed"
#define		PK_LANGUAGE_URL		@"pref_language_url"
#define		PK_GAME_URL			@"pref_game_url"
#define		PK_LEVEL_SET		@"pref_level_set"
#define		PK_BRAND			@"pref_brand"
#define		PK_CATALOG			@"pref_catalog"

#define		PK_LANG_WHITELIST	@"pref_lang_whitelist"
#define		PK_LANG_BLACKLIST	@"pref_lang_blacklist"

#define		PK_LANG_DEFAULT		@"pref_default_language"
#define		PK_LANG_DEFAULT_PREV @"pref_default_language_prev"

#define		PK_IDENTITIES		@"_identities"
#define		PK_IDENTITIY_KEY	@"_identity_%@_%@"

@class GameLevel;

@protocol UserPrefsDelegate;
@interface UserPrefs : NSObject {
}
+(void)init;

+(BOOL)hasKey:(NSString*)key;

+(NSString*)getString:(NSString*)key withDefault:(NSString*)value;
+(void)setString:(NSString*)key withValue:(NSString*)value force:(BOOL)force;
+(void)setString:(NSString*)key withValue:(NSString*)value;
+(int)getInteger:(NSString*)key withDefault:(int)value;
+(void)setInteger:(NSString*)key withValue:(int)value;
+(BOOL)getBoolean:(NSString*)key withDefault:(BOOL)value;
+(void)setBoolean:(NSString*)key withValue:(BOOL)value;
+(float)getFloat:(NSString*)key withDefault:(float)value;
+(void)setFloat:(NSString*)key withValue:(float)value;

+(NSArray*)getArray:(NSString*)key withDefault:(NSArray*)value;
+(void)setArray:(NSString*)key withValue:(NSArray*)value;

+(NSDictionary*)getDictionary:(NSString*)key withDefault:(NSDictionary*)value;
+(void)setDictionary:(NSString*)key withValue:(NSDictionary*)value;

+(id)getObject:(NSString*)key withDefault:(id)value;
+(void)setObject:(NSString*)key withValue:(id)value;

+(BOOL)levelEnabled:(NSString*)uuid;
+(void)setLevelEnabled:(NSString*)uuid enabled:(BOOL)value;

+(BOOL)levelExhausted:(GameLevel*)level;
+(void)setLevelExhausted:(GameLevel*)level passed:(BOOL)value;

+(BOOL)levelPassed:(GameLevel*)level;
+(void)setLevelPassed:(GameLevel*)level passed:(BOOL)value;



+(NSString*)key:(NSString*)key forUuid:(NSString*)uuid;


+(NSString*)userIdentity;
+(NSString*)userNick;

+(void)addKeyDelegate:(id<UserPrefsDelegate>)delegate forKey:(NSString*)key;
+(void)removeKeyDelegate:(id<UserPrefsDelegate>)delegate forKey:(NSString*)key;

+(void)removeKey:(NSString*)key;
+(void)removeByPrefix:(NSString*)prefix;
+(void)removeAll;

+(NSArray*)listKeysWithPrefix:(NSString*)prefix;
+(void)copyKey:(NSString*)key toKey:(NSString*)toKey;

+(void)fireDelegatesForKey:(NSString*)key;

+(NSString*)getExplicitString:(NSString*)key withDefault:(NSString*)value;
+(BOOL)getExplicitBoolean:(NSString*)key withDefault:(BOOL)value;

+(NSArray*)allIdentities;
+(NSString*)identityNick:(NSString*)uuid;
+(NSString*)createIdentity:(NSString*)nick;
+(void)removeIdentity:(NSString*)uuid;
+(void)switchIdentity:(NSString*)uuid;
+(NSString*)key:(NSString*)key forIdentity:(NSString*)uuid;
+(void)logIdentities:(NSString*)message;

@end

@protocol UserPrefsDelegate<NSObject>
-(void)userPrefsKeyChanged:(NSString*)key;
@end

