//
//  RTLUtils.h
//  Board3
//
//  Created by Dror Kessler on 8/8/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTLUtils : NSObject {

}
+(NSString*)rtlString:(NSString*)s;

#define    RTL(s)    ([RTLUtils rtlString:(s)])
@end
