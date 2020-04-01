//
//  CatalogItem.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Catalog;
@interface CatalogItem : NSObject {

	NSString*		_uuid;
	NSDictionary*	_props;
	Catalog*		_catalog;
}
@property (retain) NSString* uuid;
@property (retain) NSDictionary* props;
@property (nonatomic,assign) Catalog* catalog;

-(id)initWithUUID:(NSString*)uuid andProps:(NSDictionary*)props;

-(NSDictionary*)previewProps;
-(UIImage*)bannerImage;
-(NSString*)name;
-(NSURL*)directoryUrl;
-(NSString*)assetType;
-(NSString*)assetUUID;
@end
