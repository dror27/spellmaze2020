//
//  GameManager.h
//  Board3
//
//  Created by Dror Kessler on 6/15/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPrefs.h"
#import "SplashPanel.h"

#define			PROGRAM_UUID					@"1329C440-7782-4F3D-A39C-0C9F5E482C38"

#define			GM_DEFAULT_GAME_OLD				@"9B1C1160-69EC-4D13-90F7-F4AB294615CE" // (old standard)
#define			GM_DEFAULT_GAME					@"6F161DAF-6349-2774-9B9B-A9C5DA906534" 

#define			GM_DEFAULT_GAME_PIC_OLD			@"737CFEDA-8F9A-6241-8348-8F527CC43872" // (old standard w/pic)
#define			GM_DEFAULT_GAME_PIC				@"1A767972-BDA0-B6B3-6945-CDA6488213BF"

@class GameLevelSequence;
@interface GameManager : NSObject<UserPrefsDelegate> {

}
+(GameLevelSequence*)currentGameLevelSequence;
+(NSString*)programUuid;
+(void)clearCache;

+(BOOL)gameReady:(GameLevelSequence*)seq withSplashDelegate:(id<SplashPanelDelegate>)delegate;
@end
