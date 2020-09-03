#if SCRIPTING
//
//  ByFolderGameLevelFactory.m
//  Board3
//
//  Created by Dror Kessler on 8/7/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ByFolderGameLevelFactory.h"
#import "ByScriptGameLevelFactory.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"


@implementation ByFolderGameLevelFactory

-(id)initWithFolder:(NSString*)folder
{
	NSDictionary*	props = [Folders getMutableFolderProps:folder];
	
	NSString*		scriptFile = [props stringForKey:@"script" withDefaultValue:NULL];
	if ( scriptFile )
		return [super initWithScriptPath:[folder stringByAppendingPathComponent:scriptFile]];
	else
		return [super initWithScriptPath:@"Default_Level_Script.txt"];
}

@end
#endif
