//
//  GameLevelSequenceEventsTarget.h
//  Board3
//
//  Created by Dror Kessler on 7/15/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//


@class GameLevelSequence, GameLevel;
@protocol GameLevelSequenceEventsTarget<NSObject>

-(void)sequenceFinished;
-(void)seq:(GameLevelSequence*)seq levelStarted:(GameLevel*)level;
@end
