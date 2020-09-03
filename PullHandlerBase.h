//
//  PullHandlerBase.h
//  Board3
//
//  Created by Dror Kessler on 9/25/09.
//  Copyright 2020 Dror Kessler. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PullHandlerBase : NSObject {

	NSDictionary*	_pullRequest;
}
@property (retain) NSDictionary* pullRequest;

-(id)initWithPullRequest:(NSDictionary*)pullRequest;

-(NSArray*)doPush:(NSData*)requestData withUrlSuffix:(NSString*)urlSuffix;
@end
