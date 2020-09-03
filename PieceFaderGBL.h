//
//  PieceFaderGBL.h
//  Board3
//
//  Created by Dror Kessler on 5/25/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardLogicBase.h"

@class GameLevel;

@interface PieceFaderGBL : GameBoardLogicBase {

	int						fadePace; // in milliseconds, to achive full fading
	BOOL					resetFadeOnValidWord;
}
@property int fadePace;
@property BOOL resetFadeOnValidWord;

// privates
-(void)initFade:(id<Piece>)piece;
-(void)resetFade;
-(void)incrementFade;

@end
