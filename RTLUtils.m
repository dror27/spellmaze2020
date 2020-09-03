//
//  RTLUtils.m
//  Board3
//
//  Created by Dror Kessler on 8/8/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "RTLUtils.h"
#import "NSString_Reverse.h"
#import "UIDevice_SystemVersionNumber.h"

@implementation RTLUtils

+(NSString*)rtlString:(NSString*)s
{
	// not needed?
	if ( [UIDevice systemVersionNumber] >= 3.0 )
		return s;
	
	BOOL		rtl = FALSE;
	int			charsNum = [s length];
	unichar*	chars = alloca(sizeof(unichar) * charsNum);
	
	[s getCharacters:chars];
	while ( charsNum-- && !rtl )
	{
		unichar		ch = *chars++;
		
		// hebrew?
		if ( ch >= 0x0590 && ch <= 0x05FF ||
			 ch >= 0xFB00 && ch <= 0xFB4F )
			rtl = TRUE;
		
		// arabic?
		else if ( ch >= 0x0600 && ch <= 0x06FF ||
				  ch >= 0x0750 && ch <= 0x077F ||
				  ch >= 0xFB50 && ch <= 0xFDFF ||
				  ch >= 0xFE70 && ch <= 0xFEFF )
			rtl = TRUE;
	}
	
	if ( rtl )
		s = [s reverseString];
	
	return s;
	
}

@end
