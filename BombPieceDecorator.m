//
//  BombPieceDecorator.m
//  Board3
//
//  Created by Dror Kessler on 9/4/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "BombPieceDecorator.h"
#import "BrandManager.h"

@interface BombPieceDecorator (Private)
-(UIImage*)buildImage;
@end

extern NSMutableDictionary*	globalData;

@implementation BombPieceDecorator

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
	UIImage*	image = [[BrandManager currentBrand] globalImage:@"decorator-bomb" withDefaultValue:NULL];
	if ( image )
		return image;
	
	if ( ![globalData objectForKey:@"BombPieceDecorator_image"] )
	{
		[globalData setObject:[UIImage imageNamed:@"Decoration_Bomb.gif"] forKey:@"BombPieceDecorator_image"];
	}
	
	return [globalData objectForKey:@"BombPieceDecorator_image"];
}

@end
