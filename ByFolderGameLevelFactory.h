#if SCRIPTING
//
//  ByFolderGameLevelFactory.h
//  Board3
//
//  Created by Dror Kessler on 8/7/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevelFactory.h"
#import "ByScriptGameLevelFactory.h"

@interface ByFolderGameLevelFactory : ByScriptGameLevelFactory {
	
}
-(id)initWithFolder:(NSString*)folder;

@end
#endif
