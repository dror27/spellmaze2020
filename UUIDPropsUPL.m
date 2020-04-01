//
//  UUIDPropsUPL.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UUIDPropsUPL.h"
#import "NSDictionary_TypedAccess.h"
#import "UserPrefs.h"


@implementation UUIDPropsUPL
@synthesize uuid = _uuid;
@synthesize props = _props;
@synthesize nextLayer = _nextLayer;

-(id)initWithUUID:(NSString*)uuid andProps:(NSDictionary*)props andNextLayer:(id<UserPrefsLayer>)nextLayer;
{
	if ( self = [super init] )
	{
		self.uuid = uuid;
		self.nextLayer = nextLayer;
		
		// prepend all prop names with uuid
		if ( uuid )
			self.props = [NSMutableDictionary dictionaryWithObject:props forKey:uuid];
		else
			self.props = props;
	}
	return self;
}

-(void)dealloc
{
	[_uuid release];
	[_props release];
	[_nextLayer release];
	
	[super dealloc];
}

-(BOOL)hasKey:(NSString*)key
{
	return  [_props hasKey:key] || [_nextLayer hasKey:key];
}

-(NSString*)getString:(NSString*)key withDefault:(NSString*)value
{
	if ( [_props hasKey:key] )
		return [_props stringForKey:key withDefaultValue:value];
	else
		return [_nextLayer getString:key withDefault:value];
}

-(int)getInteger:(NSString*)key withDefault:(int)value
{
	if ( [_props hasKey:key] )
		return [_props integerForKey:key withDefaultValue:value];
	else
		return [_nextLayer getInteger:key withDefault:value];
}

-(BOOL)getBoolean:(NSString*)key withDefault:(BOOL)value
{
	if ( [_props hasKey:key] )
		return [_props booleanForKey:key withDefaultValue:value];
	else
		return [_nextLayer getBoolean:key withDefault:value];
}

-(float)getFloat:(NSString*)key withDefault:(float)value
{
	if ( [_props hasKey:key] )
		return [_props floatForKey:key withDefaultValue:value];
	else
		return [_nextLayer getFloat:key withDefault:value];
}

-(id)getObject:(NSString*)key withDefault:(id)value
{
	if ( [_props hasKey:key] )
		return [_props objectForKey:key withDefaultValue:value];
	else
		return [_nextLayer getObject:key withDefault:value];	
}

@end
