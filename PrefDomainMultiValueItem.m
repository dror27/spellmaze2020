//
//  PrefDomainMultiValueItem.m
//  Board3
//
//  Created by Dror Kessler on 8/6/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import <UIKit/UIImage.h>
#import "PrefDomainMultiValueItem.h"
#import "Folders.h"
#import "UUIDUtils.h"
#import "NSDictionary_TypedAccess.h"
#import "PrefUUIDPrefsBuilder.h"
#import "SystemUtils.h"
#import "StringWithProps.h"
#import "L.h"

@interface PrefMultiValueItem (Privates)
-(NSArray*)prefsForUUID:(NSString*)uuid;
@end


@implementation PrefDomainMultiValueItem
@synthesize domain = _domain;
@synthesize roleSearchOrder = _roleSearchOrder;
@synthesize prefixTitles = _prefixTitles;
@synthesize prefixValues = _prefixValues;
@synthesize suffixTitles = _suffixTitles;
@synthesize suffixValues = _suffixValues;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDomain:(NSString*)domain andDefaultValue:(NSString*)defaultValue
{
	self.domain = domain;
	
	return [super initWithLabel:label andKey:key andTitles:nil andValues:nil andDefaultStringValue:defaultValue];
}

-(void)dealloc
{
	[_domain release];
	[_roleSearchOrder release];
	[_prefixTitles release];
	[_prefixValues release];
	[_suffixTitles release];
	[_suffixValues release];
	
	[super dealloc];
}

-(NSArray*)titles
{
	if ( !_titles )
	{
		NSMutableArray*		titles = [[[NSMutableArray alloc] init] autorelease];
		NSMutableArray*		props = [NSMutableArray array];

		if ( self.prefixTitles && self.prefixValues )
		{
			int		size = MIN([self.prefixTitles count], [self.prefixValues count]);
			for ( int n = 0 ; n < size ; n++ )
			{
				NSString*		name = [self.prefixTitles objectAtIndex:n]; 
				
				[titles addObject:name];
				[props addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"title", @"", @"subtitle", nil]];
			}
		}
		
		for ( NSDictionary* props1 in [Folders listDomainSorted:self.domain withRoleSearchOrder:self.roleSearchOrder] )
		{
			NSString		*name = [props1 objectForKey:@"name"];
			if ( !name )
				name = [props1 objectForKey:@"uuid"];
			
			NSMutableDictionary*	dict = [NSMutableDictionary dictionary];
			[dict setObject:name forKey:@"title"];
			[dict setObject:[props1 objectForKey:@"description" withDefaultValue:@""] forKey:@"subtitle"];
			
			if ( [props1 hasKey:@"item-icon"] && [props1 hasKey:@"_path"] )
			{
				NSString*	path = [[props1 stringForKey:@"_path" withDefaultValue:@""] stringByAppendingPathComponent:[props1 objectForKey:@"item-icon"]];
				UIImage*	icon = [UIImage imageWithContentsOfFile:path];
				if ( icon )
					[dict setObject:icon forKey:@"icon"];
			}
			
			[titles addObject:name];
			[props addObject:dict];
		}
		
		if ( self.suffixTitles && self.suffixValues )
		{
			int		size = MIN([self.suffixTitles count], [self.suffixValues count]);
			for ( int n = 0 ; n < size ; n++ )
			{
				NSString*		name = [self.suffixTitles objectAtIndex:n];
				
				[titles addObject:name];
				[props addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"title", @"", @"subtitle", nil]];
			}
		}
		
		self.props = props;
		self.titles = titles;
	}
	
	return _titles;
}

-(NSArray*)values
{
	if ( !_values )
	{
		NSMutableArray*		values = [[[NSMutableArray alloc] init] autorelease];
		
		if ( self.prefixTitles && self.prefixValues )
		{
			int		size = MIN([self.prefixTitles count], [self.prefixValues count]);
			for ( int n = 0 ; n < size ; n++ )
				[values addObject:[self.prefixValues objectAtIndex:n]];
		}
		
		for ( NSDictionary* props in [Folders listDomainSorted:self.domain withRoleSearchOrder:self.roleSearchOrder] )
			[values addObject:[props objectForKey:@"uuid"]];		
		
		if ( self.suffixTitles && self.suffixValues )
		{
			int		size = MIN([self.suffixTitles count], [self.suffixValues count]);
			for ( int n = 0 ; n < size ; n++ )
				[values addObject:[self.suffixValues objectAtIndex:n]];
		}
		
		self.values = values;
	}

	return _values;
}

-(BOOL)detailExistsForValue:(NSString*)value
{
	return [self prefsForUUID:value] != NULL;
}

-(PrefPage*)detailForValue:(NSString*)value
{
	NSArray*				prefs = [self prefsForUUID:value];
	if ( !prefs  )
		return NULL;
	
	PrefUUIDPrefsBuilder*	builder = [[[PrefUUIDPrefsBuilder alloc] init] autorelease];
	
	PrefPage*				page = [builder pageForUUID:value forDomain:self.domain fromArray:[prefs objectAtIndex:1]];
	page.title = [prefs objectAtIndex:0];
	
	return page;
}

-(NSArray*)prefsForUUID:(NSString*)uuid
{
	// must be a uuid
	if ( ![UUIDUtils isUUID:uuid] )
		return NULL;
	
	// get props
	NSString*			folder = [Folders findUUIDSubFolder:self.roleSearchOrder forDomain:self.domain withUUID:uuid];
	if ( !folder )
		return NULL;
	NSDictionary*		props = [Folders getMutableFolderProps:folder];
	if ( !props )
		return NULL;
	
	if ( [props arrayForKey:@"prefs" withDefaultValue:NULL] )
		return [NSArray arrayWithObjects:
				[props stringForKey:@"name" withDefaultValue: LOC(@"Preferences")],
			[props arrayForKey:@"prefs" withDefaultValue:NULL],
			NULL];
	else 
		return NULL;

}

-(void)refresh
{
	self.values = nil;
	self.titles = nil;
	self.props = nil;
	
	[super refresh];
}

@end
