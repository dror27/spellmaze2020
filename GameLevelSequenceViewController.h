//
//  GameLevelSequenceViewController.h
//  Board3
//
//  Created by Dror Kessler on 6/29/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevelSequenceEventsTarget.h"
#import "SplashPanel.h"

@class GameLevelSequence, GameLevel;
@interface GameLevelSequenceViewController : UIViewController<GameLevelSequenceEventsTarget> {

	GameLevelSequence*	_seq;
	int					levelIndex;
	GameLevel*			_level;
}
@property (retain) GameLevelSequence* seq;
@property int levelIndex;
@property (retain) GameLevel* level;
@end
