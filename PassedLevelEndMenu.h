//
//  PassedLevelEndMenu.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
	PassedLevelEndMenuContext_NextLevel = 1,
	PassedLevelEndMenuContext_RepeatLevel = 2,
	PassedLevelEndMenuContext_ContinueLevel = 3,
	PassedLevelEndMenuContext_StopPlaying = 4
} PassedLevelEndMenuContext;

@class GameLevel, GameLevelSequence;
@interface PassedLevelEndMenu : NSObject {

	GameLevel*			_level;
	GameLevelSequence*		_seq;
    UIAlertController*     _actionSheet;
	NSArray*				_buttonContextCodes;
}
-(id)initWithGameLevel:(GameLevel*)level andGameLevelSequence:(GameLevelSequence*)seq;
-(void)show;

@property (retain) GameLevel* level;
@property (nonatomic,assign) GameLevelSequence* seq;
@property (retain) NSArray* buttonContextCodes;
@property (nonatomic,assign) UIAlertController* actionSheet;

@end
