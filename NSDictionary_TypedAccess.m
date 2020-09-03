//
//  NSDictionary_TypedAccess.m
//  Board3
//
//  Created by Dror Kessler on 8/7/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "NSDictionary_TypedAccess.h"


@implementation NSDictionary (TypedAccess)

-(BOOL)hasKey:(NSString*)key
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	
	return [dict objectForKey:key] != NULL;
}

-(BOOL)booleanForKey:(NSString*)key withDefaultValue:(BOOL)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	NSNumber*	value = [dict objectForKey:key];
	BOOL		result;
	
	if ( value )
		result = [value boolValue];
	else
		result = defaultValue;
		
	return result;
}

-(int)integerForKey:(NSString*)key withDefaultValue:(int)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	NSNumber*	value = [dict objectForKey:key];
	int			result;
	
	if ( value )
		result = [value intValue];
	else
		result = defaultValue;
	
	return result;
}

-(float)floatForKey:(NSString*)key withDefaultValue:(float)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	NSNumber*	value = [dict objectForKey:key];
	float		result;
	
	if ( value )
		result = [value floatValue];
	else
		result = defaultValue;
	
	return result;
}

-(NSString*)stringForKey:(NSString*)key withDefaultValue:(NSString*)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	NSString*		value = [dict objectForKey:key];

	if ( value )
		return value;
	else
		return defaultValue;
}

-(NSArray*)arrayForKey:(NSString*)key withDefaultValue:(NSArray*)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	NSArray*		value = [dict objectForKey:key];
	
	if ( value )
		return value;
	else
		return defaultValue;
}

-(NSDictionary*)dictionaryForKey:(NSString*)key withDefaultValue:(NSDictionary*)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	NSDictionary*	value = [dict objectForKey:key];
	
	if ( value )
		return value;
	else
		return defaultValue;
}

-(id)objectForKey:(NSString*)key withDefaultValue:(id)defaultValue
{
	NSDictionary*	dict = [self leafDictionaryForKey:key leafKey:&key];
	id				value = [dict objectForKey:key];
	
	if ( value )
		return value;
	else
		return defaultValue;
}

-(NSDictionary*)leafDictionaryForKey:(NSString*)key leafKey:(NSString**)leafKeyOutput
{
	NSMutableArray*	pathComponents = [NSMutableArray arrayWithArray:[key pathComponents]];
	NSDictionary*	dict = self;
	
	if ( !pathComponents || ![pathComponents count] )
	{
		if ( leafKeyOutput )
			*leafKeyOutput = key;
		
		return dict;
	}
	
	while ( [pathComponents count] > 1 )
	{
		dict = [dict objectForKey:[pathComponents objectAtIndex:0]];
		[pathComponents removeObjectAtIndex:0];
	}
	
	if ( leafKeyOutput )
		*leafKeyOutput = [pathComponents objectAtIndex:0];
	
	return dict;
}

@end
