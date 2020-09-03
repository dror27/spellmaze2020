//
//  PrefIdentitiesMultiValueItem.m
//  Board3
//
//  Created by Dror Kessler on 10/4/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefIdentitiesMultiValueItem.h"


@implementation PrefIdentitiesMultiValueItem

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andTitles:(NSArray*)titles andValues:(NSArray*)values andDefaultStringValue:(NSString*)defaultValue;
{
	if ( self = [super initWithLabel:label andKey:key andTitles:titles andValues:values andDefaultStringValue:defaultValue] )
	{
		[UserPrefs addKeyDelegate:self forKey:PK_IDENTITIES];
		[UserPrefs addKeyDelegate:self forKey:PK_IDENTITY_NICK];
	}
	return self;
}

-(void)dealloc
{
	[UserPrefs removeKeyDelegate:self forKey:PK_IDENTITIES];
	[UserPrefs removeKeyDelegate:self forKey:PK_IDENTITY_NICK];
	
	[super dealloc];
}


-(NSArray*)titles
{
	if ( ![super titles] )
	{
		NSMutableArray*		titles = [[[NSMutableArray alloc] init] autorelease];
		
		for ( NSString* value in [self values] )
			[titles addObject:[UserPrefs identityNick:value]];
		
		[super setTitles:titles];
	}
	
	return [super titles];
}

-(NSArray*)values
{
	if ( ![super values] )
	{
		[super setValues:[UserPrefs allIdentities]];
	}
	
	return [super values];
}

-(void)setValue:(NSString*)value
{
	[UserPrefs switchIdentity:value];
	
	[super setValue:value];
}

-(void)refresh
{	
	[super setTitles:NULL];
	[super setValues:NULL];
	
	[super refresh];
}


@end
