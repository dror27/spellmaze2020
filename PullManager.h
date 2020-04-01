//
//  PullManager.h
//  Board3
//
//  Created by Dror Kessler on 9/24/09.
//  Copyright 2009 Dror Kessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PullHandler.h"

@interface PullManager : NSObject {

}
+(id<PullHandler>)pullHandlerForRequest:(NSDictionary*)pullRequest;

@end
