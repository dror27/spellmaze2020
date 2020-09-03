//
//  UIDevice_AvailableMemory.h
//  Board3
//
//  Created by Dror Kessler on 8/7/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>


@interface UIDevice (AvailableMemory)
@property(readonly) double availableMemory; // MB
@end
