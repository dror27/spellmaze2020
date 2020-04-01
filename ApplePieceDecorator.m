//
//  ApplePieceDecorator.m
//  Board3
//
//  Created by Dror Kessler on 9/4/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ApplePieceDecorator.h"
#import "BrandManager.h"

@interface ApplePieceDecorator (Private)
-(UIImage*)buildImage;
@end

extern NSMutableDictionary*	globalData;

@implementation ApplePieceDecorator

-(id)init
{
	if ( self = [super init] )
	{
		self.image = [self buildImage];
		self.xPos = 0.9;
		self.yPos = 0.1;
	}
	
	return self;
}

-(UIImage*)buildImage
{
	UIImage*	image = [[BrandManager currentBrand] globalImage:@"decorator-apple" withDefaultValue:NULL];
	if ( image )
		return image;

	if ( ![globalData objectForKey:@"ApplePieceDecorator_image"] )
	{
		[globalData setObject:[UIImage imageNamed:@"Decoration_Apple.gif"] forKey:@"ApplePieceDecorator_image"];
	}
	
	return [globalData objectForKey:@"ApplePieceDecorator_image"];
}

@end
