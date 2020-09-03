//
//  Catalog.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "Catalog.h"
#import "Folders.h"
#import "UserPrefs.h"
#import "CatalogItem.h"

extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"Catalog_current"
#define SINGLETON_KEY1		@"Catalog_delegate"

@interface Catalog_UserPrefsDelegate : NSObject<UserPrefsDelegate>
{
	
}
@end
@implementation Catalog_UserPrefsDelegate
-(void)userPrefsKeyChanged:(NSString*)key
{
	[Catalog clearCache];
}
@end

@implementation Catalog
@synthesize uuid = _uuid;
@synthesize folder = _folder;
@synthesize props = _props;
@synthesize items = _items;

+(Catalog*)currentCatalog
{
	@synchronized ([Catalog class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY1] )
		{
			Catalog_UserPrefsDelegate*	delegate = [[[Catalog_UserPrefsDelegate alloc] init] autorelease];
			
			[UserPrefs addKeyDelegate:delegate forKey:PK_CATALOG];
			[globalData setObject:delegate forKey:SINGLETON_KEY1];
			
		}
		
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			Catalog*	catalog = [[[Catalog alloc] initWithUUID:[UserPrefs getString:PK_CATALOG withDefault:DEFAULT_CATALOG]] autorelease];
			
			[globalData setObject:catalog forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

+(void)clearCache
{
	@synchronized ([Catalog class])
	{
		[globalData removeObjectForKey:SINGLETON_KEY];
	}
}

-(id)initWithUUID:(NSString*)uuid
{
	if ( self = [super init] )
	{
		self.uuid = uuid;
		self.folder = [Folders findUUIDSubFolder:NULL forDomain:DF_CATALOGS withUUID:_uuid];
		self.props = [Folders getMutableFolderProps:_folder];
		
		NSMutableDictionary*	items = [NSMutableDictionary dictionary];
		NSDictionary*			itemsProps = [_props objectForKey:@"items"];
		for ( NSString* itemUUID in [itemsProps allKeys] )
		{
			CatalogItem*	item = [[[CatalogItem alloc] initWithUUID:itemUUID andProps:[itemsProps objectForKey:itemUUID]] autorelease];
			
			item.catalog = self;
			
			[items setObject:item forKey:itemUUID];
		}
		self.items = items;
	}
	return self;
}

-(void)dealloc
{
	[_uuid release];
	[_folder release];
	[_props release];
	[_items release];
	
	[super dealloc];
}

-(NSArray*)allItems
{
	return [_items allValues];
}

-(NSArray*)itemsForDomain:(NSString*)domain
{
	if ( [domain isEqualToString:DF_LANGUAGES] )
		return [self allItems];
	else
		return [NSArray array];
}

@end
