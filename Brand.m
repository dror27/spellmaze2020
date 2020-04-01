//
//  Brand.m
//  Board3
//
//  Created by Dror Kessler on 8/14/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import <UIKit/UIImage.h>
#import <UIKit/UIImageView.h>
#import "Brand.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"
#import "BrandManager.h"
#import "UserPrefs.h"


#define	NON_NULL_OBJ_OR_VALUE(obj, value)	((id)obj != (id)_null ? obj : value)

@interface Brand (Privates)
-(UIColor*)colorProp:(NSString*)name withDefaultValue:(UIColor*)value;
-(UIFont*)fontProp:(NSString*)name size:(float)size withDefaultValue:(UIFont*)value;
-(float)floatProp:(NSString*)name withDefaultValue:(float)value;
-(int)intProp:(NSString*)name withDefaultValue:(int)value;
-(UIImage*)imageProp:(NSString*)name withDefaultValue:(UIImage*)value;
-(NSString*)stringProp:(NSString*)name withDefaultValue:(NSString*)value;
@end


@implementation Brand
@synthesize uuid = _uuid;
@synthesize folder = _folder;
@synthesize name = _name;
@synthesize props = _props;
@synthesize propObjects = _propObjects;
@synthesize defaultBackgroundColor = _defaultBackgroundColor;
@synthesize defaultForegroundColor = _defaultForegroundColor;

-(id)initWithUUID:(NSString*)uuid
{
	if ( self = [super init] )
	{
		self.uuid = uuid;
		self.folder = [Folders findUUIDSubFolder:NULL forDomain:DF_BRANDS withUUID:_uuid];
		
		if ( self.folder == NULL && ![self.uuid isEqualToString:BM_DEFAULT_BRAND] )
		{
			self.uuid = BM_DEFAULT_BRAND;
			self.folder = [Folders findUUIDSubFolder:NULL forDomain:DF_BRANDS withUUID:_uuid];			
		}
		
		self.props = [Folders getMutableFolderProps:_folder];
		self.name = [_props stringForKey:@"name" withDefaultValue:@"<brand name missing>"];
		
		self.propObjects = [[[NSMutableDictionary alloc] init] autorelease];
		
		self.defaultBackgroundColor = [UIColor blackColor];
		self.defaultForegroundColor = [UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:0.8];
		
		_null = [NSNull null];
	}
	
	return self;
}

-(void)dealoc
{
	[_uuid release];
	[_folder release];
	[_props release];
	[_name release];
	[_propObjects release];
	[_defaultBackgroundColor release];
	[_defaultForegroundColor release];
	
	[super dealloc];
}

-(UIColor*)colorProp:(NSString*)name withDefaultValue:(UIColor*)value
{
	UIColor*	color = [_propObjects objectForKey:name];
	if ( color )
		return NON_NULL_OBJ_OR_VALUE(color, value);
	
	@synchronized (_propObjects) 
	{
		NSString*	text = [_props stringForKey:name withDefaultValue:NULL];
		if ( text )
		{
			int		textLength = [text length];
			
			// format is red,green,blue,alpha or RRGGBB or RRGGBBAA
			NSArray*	comps = [text componentsSeparatedByString:@","];
			if ( [comps count] >= 3 )
			{
				// parse
				float	f[4] = {1,1,1,1};
				int		findex = 0;
				for ( NSString* comp in comps )
					f[findex++] = atof([comp UTF8String]);
				
				// build color
				color = [UIColor colorWithRed:f[0]  green:f[1] blue:f[2] alpha:f[3]];
				
				// store
				[_propObjects setObject:color forKey:name];
			} 
			else if ( [comps count] == 1 && (textLength == 6 || textLength == 8) )
			{
				unsigned int	i[4] = {0xff, 0xff, 0xff, 0xff};
				float			f[4] = {1,1,1,1};
				
				sscanf([text UTF8String], "%2x%2x%2x%2x", i, i+1, i+2, i+3);
				for ( int n = 0 ; n < 4 ; n++ )
					f[n] = (float)i[n] / 255;
				
				// build color
				color = [UIColor colorWithRed:f[0]  green:f[1] blue:f[2] alpha:f[3]];
				
				// store
				[_propObjects setObject:color forKey:name];
			}
			else
				NSLog(@"Brand:colorProp: must have 4 components, text=%@", text);
		}
		if ( !color )
			[_propObjects setObject:_null forKey:name];
	}

	return color ? color : value;
}

-(UIFont*)fontProp:(NSString*)name size:(float)size withDefaultValue:(UIFont*)value
{
	NSString*	key = [NSString stringWithFormat:@"%@:%f", name, size];
	UIFont*		font = [_propObjects objectForKey:key];
	if ( font )
		return NON_NULL_OBJ_OR_VALUE(font, value);
	
	@synchronized (_propObjects) 
	{
		NSString*	text = [_props stringForKey:name withDefaultValue:NULL];
		if ( text )
		{
			font = [UIFont fontWithName:text size:size];
			if ( font )
				[_propObjects setObject:font forKey:key];
			else
				NSLog(@"Brand:fontProp: no such font, text=%@", text);
		}
		if ( !font )
			[_propObjects setObject:_null forKey:key];
	}
	
	return font ? font : value;
}

-(float)floatProp:(NSString*)name withDefaultValue:(float)value
{
	NSNumber*		number = [_propObjects objectForKey:name];
	if ( number )
		return ((id)number != (id)_null) ? [number floatValue] : value;
	
	@synchronized (_propObjects) 
	{
		number = [_props objectForKey:name withDefaultValue:NULL];
		if ( number )
			[_propObjects setObject:number forKey:name];
		else
			[_propObjects setObject:_null forKey:name];
	}
	
	return number ? [number floatValue] : value;
}

-(int)intProp:(NSString*)name withDefaultValue:(int)value
{
	NSNumber*		number = [_propObjects objectForKey:name];
	if ( number )
		return ((id)number != (id)_null) ? [number intValue] : value;
	
	@synchronized (_propObjects) 
	{
		number = [_props objectForKey:name withDefaultValue:NULL];
		if ( number )
			[_propObjects setObject:number forKey:name];
		else
			[_propObjects setObject:_null forKey:name];
	}
	
	return number ? [number intValue] : value;
}

-(UIImage*)imageProp:(NSString*)name withDefaultValue:(UIImage*)value
{
	UIImage*		image = [_propObjects objectForKey:name];
	if ( image )
		return NON_NULL_OBJ_OR_VALUE(image, value);
	
	@synchronized (_propObjects) 
	{
		NSString*	text = [_props stringForKey:name withDefaultValue:NULL];
		if ( text )
		{
			NSString*	path = [_folder stringByAppendingPathComponent:text];
			image = [UIImage imageWithContentsOfFile:path];
			if ( image )
				[_propObjects setObject:image forKey:name];
			else
				NSLog(@"Brand:imageProp: no such image, text=%@", text);
		}
		if ( !image )
			[_propObjects setObject:_null forKey:name];
	}
	
	return image ? image : value;
}

-(NSString*)stringProp:(NSString*)name withDefaultValue:(NSString*)value
{
	NSString*		text = [_propObjects objectForKey:name];
	if ( text )
		return NON_NULL_OBJ_OR_VALUE(text, value);
	
	@synchronized (_propObjects) 
	{
		text = [_props stringForKey:name withDefaultValue:NULL];
		if ( text )
			[_propObjects setObject:text forKey:name];
		else
			[_propObjects setObject:_null forKey:name];
	}
	
	return text ? text : value;
}

-(UIColor*)globalBackgroundColor
{
	return [self colorProp:@"global/skin/colors/background" withDefaultValue:_defaultBackgroundColor];
}

-(UIColor*)globalGridColor
{
	return [self colorProp:@"global/skin/colors/grid" withDefaultValue:_defaultForegroundColor];
}

-(UIColor*)globalTextColor
{
	return [self colorProp:@"global/skin/colors/text" withDefaultValue:_defaultForegroundColor];
}

-(UIColor*)globalColor:(NSString*)name withDefaultValue:(UIColor*)value
{
	return [self colorProp:[NSString stringWithFormat:@"global/skin/colors/%@", name] withDefaultValue:value];	
}

-(float)globalGridLineWidth
{
	return [self floatProp:@"global/skin/props/grid-line-width" withDefaultValue:1.0];	
}

-(NSString*)globalString:(NSString*)name withDefaultValue:(NSString*)defaultValue
{
	return [self stringProp:[NSString stringWithFormat:@"global/%@", name] withDefaultValue:defaultValue];		
}

-(int)globalInteger:(NSString*)name withDefaultValue:(int)defaultValue
{
	return [self intProp:[NSString stringWithFormat:@"global/%@", name] withDefaultValue:defaultValue];		
}

-(float)globalFloat:(NSString*)name withDefaultValue:(float)defaultValue
{
	return [self floatProp:[NSString stringWithFormat:@"global/%@", name] withDefaultValue:defaultValue];		
}

-(BOOL)globalBoolean:(NSString*)name withDefaultValue:(BOOL)defaultValue
{
	NSNumber*		v = [UserPrefs getObject:[NSString stringWithFormat:@"%@/%@", _uuid, name] withDefault:NULL];
	if ( v && [v isKindOfClass:[NSNumber class]] )
		return [v boolValue];
	
	return [self intProp:[NSString stringWithFormat:@"global/%@", name] withDefaultValue:defaultValue];		
}


-(UIFont*)globalDefaultFont:(float)size bold:(BOOL)bold;
{
	UIFont*		font = [self fontProp:@"global/skin/fonts/default" size:size withDefaultValue:NULL];
	
	return font ? font : (!bold ? [UIFont systemFontOfSize:size] : [UIFont boldSystemFontOfSize:size]);
}

-(UIImage*)globalImage:(NSString*)name withDefaultValue:(UIImage*)value
{
	return [self imageProp:[NSString stringWithFormat:@"global/skin/images/%@", name] withDefaultValue:value];
}

-(UIImageView*)globalImageView:(NSString*)name withDefaultValue:(UIImage*)value
{
	UIImage*	image = [self imageProp:[NSString stringWithFormat:@"global/skin/images/%@", name] withDefaultValue:value];
	if ( !image )
		return NULL;
	
	CGRect			imageFrame = CGRectMake(0, 0, image.size.width, image.size.height);
	UIImageView*	view = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
	view.image = image;
	
	return view;
}

-(Banner*)globalBanner:(NSString*)name
{
	UIImage*	image = [self imageProp:[NSString stringWithFormat:@"global/skin/banners/%@/image", name] withDefaultValue:NULL];
	if ( !image )
		return NULL;
	
	Banner*		banner = [[[Banner alloc] init] autorelease];
	CGRect		imageFrame = CGRectMake(0, 0, image.size.width, image.size.height);
	banner.imageView = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
	banner.imageView.image = image;
	
	banner.link = [self stringProp:[NSString stringWithFormat:@"global/skin/banners/%@/link", name] withDefaultValue:NULL];
	
	return banner;
}

-(NSString*)resourcePath:(NSString*)resourceName
{
	return [_folder stringByAppendingPathComponent:resourceName];
}

@end
