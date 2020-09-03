//
//  UIDevice_SystemVersionNumber.m
//  Board3
//
//  Created by Dror Kessler on 8/8/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "UIDevice_SystemVersionNumber.h"

static float UIDevice_SystemVersionNumber = 0.0;

@implementation UIDevice (SystemVersionNumber)

+(float)systemVersionNumber
{
	if ( UIDevice_SystemVersionNumber <= 0.0 )
	{
		UIDevice*	device = [UIDevice currentDevice];
		
		UIDevice_SystemVersionNumber = atof([[device systemVersion] cStringUsingEncoding:NSUTF8StringEncoding]);
	}
	
	return UIDevice_SystemVersionNumber;
}

@end
