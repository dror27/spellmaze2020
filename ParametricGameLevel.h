//
//  ParametricGameLevel.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevel.h"
#import "UserPrefsLayer.h"

@interface ParametricGameLevel : GameLevel {

	id<UserPrefsLayer>	_upl;
}
@property (retain) id<UserPrefsLayer> upl;

@end
