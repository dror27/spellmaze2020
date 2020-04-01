//
//  NSMutableArray_Suffle.m
//  Board3
//
//  Created by Dror Kessler on 9/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "NSMutableArray_Shuffle.h"


// Unbiased random rounding thingy.
NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
	
    do {
        m <<= 1;
    } while(m < n);
	
    NSUInteger ret;
	
    do {
        ret = random() % m;
    } while(ret >= n);
	
    return ret;
}

@implementation NSMutableArray (Shuffle)

- (void)shuffle {
    // http://en.wikipedia.org/wiki/Knuth_shuffle
	
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}


@end
