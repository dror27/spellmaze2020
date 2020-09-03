//
//  UIImage_ResizeImageAllocator.h
//  Board3
//
//  Created by Dror Kessler on 8/27/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIKit.h>


@interface UIImage (ResizeImageAllocator)

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
- (UIImage*)scaleImageToSize:(CGSize)newSize;
-(UIImage*)imageWithMask:(UIImage *)maskImage;
+(UIImage*)imageWithView:(UIView*)view scaledToSize:(CGSize)newSize;

@end
