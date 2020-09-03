//
//  GameLevelFactory.h
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasUUID.h"
#import "HasProps.h"

@class GameLevel, GameLevelSequence;

@protocol GameLevelFactory<HasUUID,HasProps>

-(GameLevel*)createGameLevel;
-(void)setSeq:(GameLevelSequence*)seq;
-(void)setProps:(NSDictionary*)props;

@end

