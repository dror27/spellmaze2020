//
//  PrefDomainDirectoryListingMultiValueItem.m
//  Board3
//
//  Created by Dror Kessler on 8/13/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefDomainDirectoryListingMultiValueItem.h"


@interface PrefDomainDirectoryListingMultiValueItem (Privates)
-(void)fetch;
@end


@implementation PrefDomainDirectoryListingMultiValueItem
@synthesize url = _url;
@synthesize directory = _directory;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andUrl:(NSURL*)url
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.url = url;
	}
	return self;
}

-(void)dealloc
{
	[_url release];
	[_directory release];
	
	[super dealloc];
}

-(NSArray*)titles
{
	if ( ![super titles] )
	{
		NSMutableArray*		titles = [[[NSMutableArray alloc] init] autorelease];

		[self fetch];
		for ( NSDictionary* item in self.directory )
			[titles addObject:[item objectForKey:@"title"]];
		
		[super setTitles:titles];
	}
	
	return [super titles];
}

-(NSArray*)values
{
	if ( ![super values] )
	{
		NSMutableArray*		values = [[[NSMutableArray alloc] init] autorelease];
		
		[self fetch];
		for ( NSDictionary* item in self.directory )
			[values addObject:[item objectForKey:@"title"]];
		
		[super setValues:values];
	}
	
	return [super values];
}

-(void)fetch
{
	// already loaded?
	if ( self.directory )
		return;
	
	// fetch from url
	NSData*					data = [[[NSData alloc] initWithContentsOfURL:self.url] autorelease];
	NSString*				error;
	NSPropertyListFormat	format;
	NSDictionary*			props = [NSPropertyListSerialization propertyListFromData:data 
																  mutabilityOption:NSPropertyListImmutable 
																			format:&format
																  errorDescription:&error];

	// assign
	self.directory = [props objectForKey:@"items"];
}

-(void)refresh
{	
	[super setTitles:NULL];
	[super setValues:NULL];
	self.directory = NULL;
	
	[super refresh];
}

@end
