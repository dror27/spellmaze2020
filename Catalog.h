//
//  Catalog.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BrandManager.h"
#import "Brand.h"

#define	DEFAULT_CATALOG		([[BrandManager currentBrand] globalString:@"catalog/props/default" withDefaultValue:@"219DBCDC-9B28-CBDF-B187-3E458507EE32"])

@interface Catalog : NSObject {

	NSString*		_uuid;
	NSString*		_folder;
	NSDictionary*	_props;
	
	NSDictionary*	_items;
	
}
@property (retain) NSString* uuid;
@property (retain) NSString* folder;
@property (retain) NSDictionary* props;
@property (retain) NSDictionary* items;

+(Catalog*)currentCatalog;
+(void)clearCache;

-(id)initWithUUID:(NSString*)uuid;
-(NSArray*)allItems;
-(NSArray*)itemsForDomain:(NSString*)domain;


@end
