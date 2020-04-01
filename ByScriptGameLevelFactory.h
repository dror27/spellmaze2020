#if SCRIPTING
//
//  ByScriptGameLevelFactory.h
//  Board3
//
//  Created by Dror Kessler on 5/29/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevelFactory.h"

@class GameLevelSequence;
@interface ByScriptGameLevelFactory : NSObject<GameLevelFactory> {

	NSString*	_scriptPath;
	NSString*	_script;
	
	NSDictionary*	_props;
	NSString*		_uuid;
	
	GameLevelSequence* _seq;
}
@property (retain) NSString* scriptPath;
@property (retain) NSString* script;
@property (retain) NSDictionary* props;
@property (retain) NSString* uuid;
@property (nonatomic,assign) GameLevelSequence* seq;


-(id)initWithScriptPath:(NSString*)scriptPath;
-(id)initWithScript:(NSString*)script;

@end
#endif
