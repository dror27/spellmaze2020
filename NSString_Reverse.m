//
//  NSString_Reverse.m
//  Board3
//
//  Created by Dror Kessler on 5/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "NSString_Reverse.h"

@implementation NSString (reverse)

-(NSString *)reverseString
{
	NSMutableString *reversedStr;
	int len = [self length];
	
	// Auto released string
	reversedStr = [NSMutableString stringWithCapacity:len];     
	
	// Probably woefully inefficient...
	while (len > 0)
		[reversedStr appendString:
         [NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];   
	
	return reversedStr;
}

@end
