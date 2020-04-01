//
//  PrefMainPageBuilder.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefUrlDirectorySection.h"
#import "PrefPage.h"
#import "PrefItemBase.h"

@class PrefPage;
@interface PrefMainPageBuilder : NSObject<PrefUrlDirectoryDelegate> {

}
-(PrefPage*)buildPrefPage;

+(void)pushIntoDetail:(NSArray*)args;
+(PrefItemBase*)findStartupItemInPage:(PrefPage*)page;


@end
