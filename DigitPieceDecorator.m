//
//  DigitPieceDecorator.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/27/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "DigitPieceDecorator.h"
#import "BrandManager.h"
#import "ShapeDecorationImageBuilder.h"

extern NSMutableDictionary*	globalData;

@interface DigitPieceDecorator_Delegate : NSObject<BrandManagerDelegate>
{
}
@end
@implementation DigitPieceDecorator_Delegate
-(void)brandDidChange:(Brand*)brand
{
	[globalData removeObjectForKey:@"DigitPieceDecorator_image"];
}
@end

@interface DigitPieceDecorator (Private)
-(UIImage*)buildImage;
@end

@implementation DigitPieceDecorator

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
	if ( ![globalData objectForKey:@"DigitPieceDecorator_image"] )
	{
		ShapeDecorationImageBuilder*	builder = [[[ShapeDecorationImageBuilder alloc] init] autorelease];
		
		builder.shapeFillColor = [[BrandManager currentBrand] globalColor:@"digit-decorator" 
														 withDefaultValue:[UIColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1]];
		
		builder.symbolLines = [NSArray array];
		builder.text = @"5";
		
		
		[globalData setObject:[builder image] forKey:@"DigitPieceDecorator_image"];
	}
	
	if ( ![globalData objectForKey:@"DigitPieceDecorator_delegate"] )
	{
		id<BrandManagerDelegate>	delegate = [[DigitPieceDecorator_Delegate alloc] init];
		
		[globalData setObject:delegate forKey:@"DigitPieceDecorator_delegate"];
		[[BrandManager singleton] addDelegate:delegate];
	}
	
	return [globalData objectForKey:@"DigitPieceDecorator_image"];
}



@end
