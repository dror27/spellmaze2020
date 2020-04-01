//
//  SystemUtils.h
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#define		THREAD_STACK_SIZE		0x10000


@interface SystemUtils : NSObject {

}
+(NSString*)softwareVersion;
+(NSString*)softwareBuild;
+(NSDate*)expirationDate;
+(BOOL)hasExpired;

+(BOOL)autorun;
+(float)autorunDelay;
+(BOOL)autorunLevelLoop;
+(BOOL)autorunGameLoop;
+(BOOL)autorunAccumulateScore;

+(NSThread*)threadWithTarget:(id)target selector:(SEL)selector object:(id)object;

@end
