//
//  RandomPlacementGameBoardLogic.h
//  Board3
//
//  Created by Dror Kessler on 5/22/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardLogic.h"
#import "GameBoardLogicBase.h"

@class GameLevel;

@interface RandomPlacementGBL : GameBoardLogicBase {
	
	BOOL		alwaysRandomPlacement;
	BOOL		pauseAtWordEnd;
	int			pauseSkipCount;
}
@property BOOL alwaysRandomPlacement;
@property BOOL pauseAtWordEnd;
@property int pauseSkipCount;
@end
