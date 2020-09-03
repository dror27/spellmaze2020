//
//  CheckedPieceDecorator.m
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "CheckedPieceDecorator.h"
#import "ShapeDecorationImageBuilder.h"
#import "BrandManager.h"

extern NSMutableDictionary*	globalData;

@interface CheckedPieceDecorator_Delegate : NSObject<BrandManagerDelegate>
{
}
@end
@implementation CheckedPieceDecorator_Delegate
-(void)brandDidChange:(Brand*)brand
{
	[globalData removeObjectForKey:@"CheckedPieceDecorator_image"];
}
@end

@interface CheckedPieceDecorator (Private)
-(UIImage*)buildImage;
@end

@implementation CheckedPieceDecorator

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
	if ( ![globalData objectForKey:@"CheckedPieceDecorator_image"] )
	{
		ShapeDecorationImageBuilder*	builder = [[[ShapeDecorationImageBuilder alloc] init] autorelease];
		
		builder.shapeFillColor = [[BrandManager currentBrand] globalColor:@"checked-decorator" 
														 withDefaultValue:[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1]];
		
		builder.symbolLines = [NSArray arrayWithObject:
								[NSArray arrayWithObjects:
								 [NSValue valueWithCGPoint:CGPointMake(-0.5, 0)],
								 [NSValue valueWithCGPoint:CGPointMake(-0.2, 0.3)],
								 [NSValue valueWithCGPoint:CGPointMake(0.5, -0.4)],
								 NULL]];
								
		
		[globalData setObject:[builder image] forKey:@"CheckedPieceDecorator_image"];
	}

	if ( ![globalData objectForKey:@"CheckedPieceDecorator_delegate"] )
	{
		id<BrandManagerDelegate>	delegate = [[CheckedPieceDecorator_Delegate alloc] init];
		
		[globalData setObject:delegate forKey:@"CheckedPieceDecorator_delegate"];
		[[BrandManager singleton] addDelegate:delegate];
	}

	return [globalData objectForKey:@"CheckedPieceDecorator_image"];
}



@end
