//
//  ShapeDecorationImageBuilder.m
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ShapeDecorationImageBuilder.h"


@implementation ShapeDecorationImageBuilder
@synthesize shapeBorderColor = _shapeBorderColor;
@synthesize shapeFillColor = _shapeFillColor;
@synthesize	symbolColor = _symbolColor;
@synthesize symbolLines = _symbolLines;
@synthesize radius = _radius;
@synthesize text = _text;

-(void)dealloc
{
	[_shapeBorderColor release];
	[_shapeFillColor release];
	[_symbolColor release];
	[_symbolLines release];
	[_text release];
	
	[super dealloc];
}

-(id)init
{
	if ( self = [super init] )
	{
		// colors
		self.shapeBorderColor = [UIColor whiteColor];
		self.shapeFillColor = [UIColor greenColor];
		self.symbolColor = [UIColor whiteColor];
	
		// simple cross
		self.symbolLines = [NSArray arrayWithObjects:
								[NSArray arrayWithObjects:
									[NSValue valueWithCGPoint:CGPointMake(-0.6, 0)],
									[NSValue valueWithCGPoint:CGPointMake(+0.6, 0)],
									NULL],
								[NSArray arrayWithObjects:
									[NSValue valueWithCGPoint:CGPointMake(0, -0.6)],
									[NSValue valueWithCGPoint:CGPointMake(0, +0.6)],
									NULL],
							NULL];
		
		// othre
		self.radius = 12;
	}
	
	return self;
}

-(UIImage*)image
{
	UIGraphicsBeginImageContext(CGSizeMake(self.radius * 2, self.radius * 2));		
	CGContextRef context = UIGraphicsGetCurrentContext();		
	UIGraphicsPushContext(context);								

	// draw circle
	CGContextSetStrokeColorWithColor(context, self.shapeBorderColor.CGColor);
	CGContextSetFillColorWithColor(context, self.shapeFillColor.CGColor);
	CGContextSetLineWidth(context, 2.5);
	double			radius = self.radius;
	double			centerX = radius;
	double			centerY = radius;
	CGContextAddArc(context, centerX, centerY, radius - 3, 0, 2 * M_PI, 1);
	CGContextFillPath(context);
	CGContextAddArc(context, centerX, centerY, radius - 2, 0, 2 * M_PI, 1);
	CGContextStrokePath(context);

	// draw symbol
	CGContextSetStrokeColorWithColor(context, self.symbolColor.CGColor);
	CGContextSetLineWidth(context, 4.0);
	for ( NSArray* linePoints in _symbolLines )
	{
		int				pointCount = [linePoints count];
		CGPoint			*points = alloca(sizeof(CGPoint) * pointCount);
		int				pointIndex;
		
		for ( pointIndex = 0 ; pointIndex < pointCount ; pointIndex++ )
		{
			// get (factors) point
			NSValue*	pointValue = [linePoints objectAtIndex:pointIndex];
			CGPoint		point = [pointValue CGPointValue];
			
			// calc point
			points[pointIndex].x = point.x * radius + centerX;
			points[pointIndex].y = point.y * radius + centerY;
		}
		CGContextAddLines(context, points, pointCount);		
	}
	CGContextStrokePath(context);
	
	UIGraphicsPopContext();								
	UIImage*	image = [[UIGraphicsGetImageFromCurrentImageContext() retain] autorelease];
	UIGraphicsEndImageContext();
	
	return image;
}
@end
