//
//  UserPrefsUPL.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UserPrefsUPL.h"
#import "UserPrefs.h"


@implementation UserPrefsUPL

-(BOOL)hasKey:(NSString*)key
{
	return [UserPrefs hasKey:key];
}

-(NSString*)getString:(NSString*)key withDefault:(NSString*)value
{
	return [UserPrefs getString:key withDefault:value];
}

-(int)getInteger:(NSString*)key withDefault:(int)value
{
	return [UserPrefs getInteger:key withDefault:value];
}

-(BOOL)getBoolean:(NSString*)key withDefault:(BOOL)value
{
	return [UserPrefs getBoolean:key withDefault:value];
}

-(float)getFloat:(NSString*)key withDefault:(float)value
{
	return [UserPrefs getFloat:key withDefault:value];
}

-(id)getObject:(NSString*)key withDefault:(id)value
{
	return [UserPrefs getObject:key withDefault:value];
}

@end
