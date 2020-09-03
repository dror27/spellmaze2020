//
//  NSMutableString_Shuffle.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/10/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "NSMutableString_Shuffle.h"
extern NSUInteger random_below(NSUInteger n);


@implementation NSMutableString (Shuffle)

- (void)shuffle {
    // http://en.wikipedia.org/wiki/Knuth_shuffle
	
	int			length = [self length];
	unichar*	chars = alloca(sizeof(unichar) * length);
	
	[self getCharacters:chars];
	
    for(NSUInteger i = length; i > 1; i--) 
	{
        NSUInteger j = random_below(i);
		
		unichar		tmp = chars[j];
		chars[j] = chars[i-1];
		chars[i-1] = tmp;
    }
	
	[self setString:[NSString stringWithCharacters:chars length:length]];
}

@end
