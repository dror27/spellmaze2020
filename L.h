//
//  L.h
//  Board3
//
//  Created by Dror Kessler on 9/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface L : NSObject {

}
+(NSString*)l:(NSString*)s;
+(NSString*)lrtl:(NSString*)s;

@end

#define        LOC(s)    ([L l:(s)])
#define        LOC_RTL(s)    ([L lrtl:(s)])

