#if SCRIPTING
//
//  ByUUIDGameLevelFactory.m
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ByUUIDGameLevelFactory.h"
#import "ByScriptGameLevelFactory.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"


@implementation ByUUIDGameLevelFactory

-(id)initWithUUID:(NSString*)uuid
{
	NSDictionary*				props = [Folders findUUIDProps:NULL forDomain:DF_LEVELS withUUID:uuid];

	self = [self initWithProps:props];
	
	self.uuid = uuid;
	
	return self;
}

-(id)initWithProps:(NSDictionary*)props
{
	NSString*		scriptFile = [props stringForKey:@"script" withDefaultValue:NULL];
	if ( scriptFile )
	{
		NSString*	folder = [props stringForKey:@"__baseFolder" withDefaultValue:@"."];
		self = [super initWithScriptPath:[folder stringByAppendingPathComponent:scriptFile]];
	}
	else
		@throw [NSException exceptionWithName:@"script missing" reason:_uuid userInfo:NULL];
	
	if ( !self.uuid && [props objectForKey:@"uuid"] )
		self.uuid = [props objectForKey:@"uuid"];
	
	return self;
}



@end
#endif
