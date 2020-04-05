//
//  Brand.h
//  Board3
//
//  Created by Dror Kessler on 8/14/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Banner.h"

@interface Brand : NSObject {

	NSString*			_uuid;
	NSString*			_folder;
	NSString*			_name;
	NSDictionary*		_props;
	
	NSMutableDictionary* _propObjects;
	
	UIColor*			_defaultBackgroundColor;
	UIColor*			_defaultForegroundColor;
	
	NSNull*				_null;
}
@property (retain) NSString* uuid;
@property (retain) NSString* folder;
@property (retain) NSString* name;
@property (retain) NSDictionary* props;
@property (retain) NSMutableDictionary* propObjects;
@property (retain) UIColor* defaultBackgroundColor;
@property (retain) UIColor* defaultForegroundColor;


-(id)initWithUUID:(NSString*)uuid;

-(UIColor*)globalBackgroundColor;
-(UIColor*)globalGridColor;
-(UIColor*)globalTextColor;
-(UIColor*)globalColor:(NSString*)name withDefaultValue:(UIColor*)value;

-(UIImage*)globalImage:(NSString*)name withDefaultValue:(UIImage*)value;
-(UIImageView*)globalImageView:(NSString*)name withDefaultValue:(UIImage*)value;
-(UIImageView*)globalImageView:(NSString*)name withDefaultValue:(UIImage*)value withSizeFromView:(UIView*)sizeView;

-(Banner*)globalBanner:(NSString*)name;


-(float)globalGridLineWidth;

-(NSString*)globalString:(NSString*)name withDefaultValue:(NSString*)defaultValue;
-(int)globalInteger:(NSString*)name withDefaultValue:(int)defaultValue;
-(float)globalFloat:(NSString*)name withDefaultValue:(float)defaultValue;
-(BOOL)globalBoolean:(NSString*)name withDefaultValue:(BOOL)defaultValue;

-(UIFont*)globalDefaultFont:(float)size bold:(BOOL)bold;

-(NSString*)resourcePath:(NSString*)resourceName;

@end
