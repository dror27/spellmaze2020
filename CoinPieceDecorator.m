//
//  CoinPieceDecorator.m
//  Board3
//
//  Created by Dror Kessler on 9/4/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "CoinPieceDecorator.h"
#import "BrandManager.h"

@interface CoinPieceDecorator (Private)
-(UIImage*)buildImage;
@end

extern NSMutableDictionary*	globalData;

@implementation CoinPieceDecorator

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
	UIImage*	image = [[BrandManager currentBrand] globalImage:@"decorator-coin" withDefaultValue:NULL];
	if ( image )
		return image;
	
	if ( ![globalData objectForKey:@"CoinPieceDecorator_image"] )
	{
		[globalData setObject:[UIImage imageNamed:@"Decoration_Coin.gif"] forKey:@"CoinPieceDecorator_image"];
	}
	
	return [globalData objectForKey:@"CoinPieceDecorator_image"];
}

@end
