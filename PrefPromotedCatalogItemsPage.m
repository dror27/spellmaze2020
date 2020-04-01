//
//  PrefPromotedCatalogItemsPage.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefPromotedCatalogItemsPage.h"
#import "CatalogItem.h"
#import "PrefSection.h"
#import "PrefImageSequenceItem.h"
#import "PrefLabelItem.h"
#import "PrefUrlDirectorySection.h"
#import "PrefPageItem.h"
#import "PrefImageItem.h"
#import "L.h"

@implementation PrefPromotedCatalogItemsPage
@synthesize catalogItems = _catalogItems;

-(id)initWithCatalogItems:(NSArray*)catalogItems
{
	if ( self = [super init] )
	{
		self.catalogItems = catalogItems;
	}
	return self;
}

-(void)dealloc
{
	[_catalogItems release];
	
	[super dealloc];
}

-(NSArray*)sections
{
	if ( ![super sections] && [_catalogItems count] )
	{
		CatalogItem*			item = [_catalogItems objectAtIndex:0];
		NSString*				folder = [[item catalog] folder];
		NSDictionary*			previewProps = [item previewProps];
		
		PrefSection*			section = [[[PrefSection alloc] init] autorelease];
		PrefImageItem*			labelItem = [[[PrefImageItem alloc] initWithLabel:nil andKey:nil andImage:[item bannerImage]] autorelease];
		PrefImageSequenceItem*	previewItem = [[[PrefImageSequenceItem alloc] initWithLabel:NULL andKey:NULL andFolder:folder andProps:previewProps] autorelease];
		section.items = [NSArray arrayWithObjects:labelItem, previewItem, nil];
		
		NSURL*						url = [item directoryUrl];
		PrefUrlDirectorySection*	downloadSection = [[[PrefUrlDirectorySection alloc] initWithURL:url] autorelease];
		if ( [[item assetType] isEqualToString:@"item"] )
			[downloadSection setLimitToItemUUID:[item assetUUID]];
		downloadSection.title = LOC(@"Buy It Now!:");
		
		[super setSections:[NSArray arrayWithObjects:section, downloadSection, nil]];
	}
	return [super sections];
}

@end
	
