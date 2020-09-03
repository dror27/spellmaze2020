//
//  CheckedPieceDecorator.m
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "CheckedPieceDecorator2.h"
#import "ShapeDecorationImageBuilder.h"
#import "BrandManager.h"

extern NSMutableDictionary*	globalData;

@interface CheckedPieceDecorator2_Delegate : NSObject<BrandManagerDelegate>
{
}
@end
@implementation CheckedPieceDecorator2_Delegate
-(void)brandDidChange:(Brand*)brand
{
	[globalData removeObjectForKey:@"CheckedPieceDecorator2_image"];
}
@end

@interface CheckedPieceDecorator2 (Private)
-(UIImage*)buildImage;
@end

@implementation CheckedPieceDecorator2

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
	if ( ![globalData objectForKey:@"CheckedPieceDecorator2_image"] )
	{
		ShapeDecorationImageBuilder*	builder = [[[ShapeDecorationImageBuilder alloc] init] autorelease];
		
		builder.shapeFillColor = [[BrandManager currentBrand] globalColor:@"checked-decorator" 
														 withDefaultValue:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
		
		builder.symbolLines = [NSArray arrayWithObjects:
								/*
							   [NSArray arrayWithObjects:
								[NSValue valueWithCGPoint:CGPointMake(-0.5, 0)],
								[NSValue valueWithCGPoint:CGPointMake(-0.2, 0.3)],
								[NSValue valueWithCGPoint:CGPointMake(0.5, -0.4)],
								NULL],
								*/
							   [NSArray arrayWithObjects:
								[NSValue valueWithCGPoint:CGPointMake(-0.5, 0)],
								[NSValue valueWithCGPoint:CGPointMake(0.5, 0)],
								NULL],
							   [NSArray arrayWithObjects:
								[NSValue valueWithCGPoint:CGPointMake(0, -0.5)],
								[NSValue valueWithCGPoint:CGPointMake(0, 0.5)],
								NULL],
							   NULL
							   ];
		
		
		[globalData setObject:[builder image] forKey:@"CheckedPieceDecorator2_image"];
	}
	
	if ( ![globalData objectForKey:@"CheckedPieceDecorator2_delegate"] )
	{
		id<BrandManagerDelegate>	delegate = [[CheckedPieceDecorator2_Delegate alloc] init];
		
		[globalData setObject:delegate forKey:@"CheckedPieceDecorator2_delegate"];
		[[BrandManager singleton] addDelegate:delegate];
	}
	
	return [globalData objectForKey:@"CheckedPieceDecorator2_image"];
}



@end
