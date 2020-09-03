//
//  CatalogItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "CatalogItem.h"
#import "Catalog.h"
#import "NSDictionary_TypedAccess.h"
#import "PrefUrlDirectorySection.h"

@implementation CatalogItem
@synthesize uuid = _uuid;
@synthesize props = _props;
@synthesize catalog = _catalog;

-(id)initWithUUID:(NSString*)uuid andProps:(NSDictionary*)props
{
	if ( self = [super init] )
	{
		self.uuid = uuid;
		self.props = props;
	}
	return self;
}

-(void)dealloc
{
	[_uuid release];
	[_props release];
	
	[super dealloc];
}	

-(NSDictionary*)previewProps
{
	return [_props objectForKey:@"preview"];
}

-(UIImage*)bannerImage
{
	return [UIImage imageWithContentsOfFile:[[_catalog folder] stringByAppendingPathComponent:[_props objectForKey:@"banner"]]];
}

-(NSString*)name
{
	return [_props objectForKey:@"name"];
}

-(NSURL*)directoryUrl
{
	NSURL*		url = [NSURL URLWithString:[_props stringForKey:@"asset/url" withDefaultValue:@""]];
	
	url = [PrefUrlDirectorySection enrichDownloadUrl:url withAdditionalSuffix:nil];
	
	return url;
}

-(NSString*)assetType
{
	return [_props stringForKey:@"asset/type" withDefaultValue:@""];
}

-(NSString*)assetUUID
{
	return [_props stringForKey:@"asset/uuid" withDefaultValue:@""];	
}
@end
