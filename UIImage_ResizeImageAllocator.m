//
//  UIImage_ResizeImageAllocator.m
//  Board3
//
//  Created by Dror Kessler on 8/27/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "UIImage_ResizeImageAllocator.h"
#import	<QuartzCore/QuartzCore.h>

@implementation UIImage (ResizeImageAllocator)

+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

-(UIImage*)scaleImageToSize:(CGSize)newSize
{
	return [UIImage imageWithImage:self scaledToSize:newSize];
}

-(UIImage*)imageWithMask:(UIImage *)maskImage 
{	
	CGImageRef maskRef = maskImage.CGImage; 
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef		masked = CGImageCreateWithMask([self CGImage], mask);
	UIImage*		image = [UIImage imageWithCGImage:masked];

	CFRelease(mask);
	CFRelease(masked);
	
	return image;
}

static void renderViewInContextAndSubViews(UIView* view)
{
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	for ( UIView* subView in [view subviews] )
		renderViewInContextAndSubViews(subView);
}

+(UIImage*)imageWithView:(UIView*)view scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContext(newSize);
	renderViewInContextAndSubViews(view);
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
	
}
	
@end
