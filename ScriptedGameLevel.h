#if SCRIPTING
//
//  ScriptedGameLevel.h
//  Board3
//
//  Created by Dror Kessler on 5/29/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevel.h"
#import "JIMInterp.h"

@interface ScriptedGameLevel : GameLevel {

	JIMInterp*		_interp;
}
@property (retain) JIMInterp* interp;

-(id)initWithScript:(NSString*)script andProps:(NSDictionary*)props;
-(id)initWithScriptPath:(NSString*)scriptPath andProps:(NSDictionary*)props;


@end
#endif
