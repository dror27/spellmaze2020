/*
 *  GameLevelEventsTarget.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/16/09.
 *  Copyright 2020 Dror Kessler (M). All rights reserved.
 *
 */
@class GameLevel;

@protocol GameLevelEventsTarget <NSObject>

-(void)passedLevel:(GameLevel*)level withMessage:(NSString*)message andContext:(void*)context;
-(void)failedLevel:(GameLevel*)level withMessage:(NSString*)message andContext:(void*)context;
-(void)abortedLevel:(GameLevel*)level;

@end
