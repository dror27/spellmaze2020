#if SCRIPTING
//
//  JIMHelper.m
//  Board3
//
//  Created by Dror Kessler on 5/22/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "JIMHelper.h"


@implementation JIMHelper

+(NSString*)string:(Jim_Obj*)obj
{
	return [NSString stringWithUTF8String:Jim_GetString(obj, NULL)];
}

@end
#endif
