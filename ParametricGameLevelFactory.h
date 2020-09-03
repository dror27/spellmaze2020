//
//  ProgrammableGameLevelFactory.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/20/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevelFactory.h"

@class GameLevelSequence;
@interface ParametricGameLevelFactory : NSObject<GameLevelFactory> {

	NSDictionary*	_props;
	NSString*		_uuid;
	
	GameLevelSequence* _seq;
	
}
@property (retain) NSDictionary* props;
@property (retain) NSString* uuid;
@property (nonatomic,assign) GameLevelSequence* seq;

-(id)initWithUUID:(NSString*)uuid;
-(id)initWithProps:(NSDictionary*)props;

@end
