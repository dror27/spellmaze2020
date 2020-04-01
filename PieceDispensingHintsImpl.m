//
//  PieceDispensingHintsImpl.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PieceDispensingHintsImpl.h"


@implementation PieceDispensingHintsImpl
@synthesize hints = _hints;

-(id)init
{
	if ( self = [super init] )
	{
		self.hints = [[[NSMutableDictionary alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[_hints release];
	
	[super dealloc];
}

-(void)addStringHint:(NSString*)name withValue:(NSString*)value
{
	[_hints setObject:value forKey:name];
}

-(void)addIntHint:(NSString*)name withValue:(int)value
{
	NSString*		stringValue = [NSString stringWithFormat:@"%d", value];
	[_hints setObject:stringValue forKey:name];
}		

-(BOOL)hasHint:(NSString*)name
{
	return [_hints objectForKey:name] != NULL;
}

-(NSString*)stringHint:(NSString*)name
{
	return [_hints objectForKey:name];
}

-(int)intHint:(NSString*)name
{
	NSString*	value = [_hints objectForKey:name];
	
	if ( value )
	{
		return [value intValue];
	}
	else
		return -1;
}


@end
