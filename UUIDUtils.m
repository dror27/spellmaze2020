//
//  UUIDUtils.m
//  Board3
//
//  Created by Dror Kessler on 8/26/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "UUIDUtils.h"


@implementation UUIDUtils

+(NSString*)createUUID
{
	CFUUIDRef	uuidRef = CFUUIDCreate(NULL);
	CFStringRef	strRef = CFUUIDCreateString(NULL, uuidRef);
	NSString*	newUUID = [NSString stringWithFormat:@"%@", strRef];
	
	CFRelease(uuidRef);
	CFRelease(strRef);
	
	return newUUID;	
}

+(BOOL)isUUID:(NSString*)uuid
{
	return uuid && [uuid length] == 36;
}

+(NSString*)strip:(NSString*)uuid
{
	return [[uuid lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];	
}


@end
