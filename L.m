//
//  L.m
//  Board3
//
//  Created by Dror Kessler on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "L.h"
#import "NSString_Reverse.h"

//#define		DUMP

static BOOL			initialized = FALSE;
static BOOL			rtl = FALSE;
static NSBundle*	mainBundle = NULL;

static void init()
{
	if ( !initialized )
	{
		mainBundle = [NSBundle mainBundle];
		if ( [[mainBundle localizedStringForKey:@"rtl" value:@"false" table:nil] isEqualToString:@"true"] )
			rtl = TRUE;
#ifdef DUMP
		NSLog(@"%@", [[NSLocale systemLocale] objectForKey:NSLocaleLanguageCode]);
		NSLog(@"%@", [[NSLocale systemLocale] objectForKey:NSLocaleCountryCode]);
		NSLog(@"%@", [[NSBundle mainBundle] localizations]);
		NSLog(@"%@", [[NSBundle mainBundle] localizedInfoDictionary]);
#endif
		
		initialized = TRUE;
	}
}
	

@implementation L

+(NSString*)l:(NSString*)s
{
	init();
	
	NSString	*localized = [mainBundle localizedStringForKey:s value:s table:nil];
	return localized;
}

+(NSString*)lrtl:(NSString*)s
{
	NSString	*localized = [L l:s];
	
	if ( rtl )
		localized = [localized reverseString];
	
	return localized;
	
}


@end
