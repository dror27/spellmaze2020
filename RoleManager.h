//
//  RoleManager.h
//  Board3
//
//  Created by Dror Kessler on 9/2/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPrefs.h"
#import "StringTransformer.h"
#import "NSDictionary_TypedAccess.h"


@interface RoleManager : NSObject<UserPrefsDelegate,StringTransformer> {

	NSMutableDictionary*	_cheats;
}
@property (retain) NSMutableDictionary* cheats;

+(RoleManager*)singleton;

-(NSString*)filteredNickname;
-(NSString*)filteredNicknameFromNick:(NSString*)nick;

#define	CHEAT_ON(c)						([[[RoleManager singleton] cheats] hasKey:c])

#define	CHEAT_OLD_IMAGE_HINTS			@"oih"
#define CHEAT_WIDE_CELLS				@"wc"

#define	CHEAT_AUTORUN					@"ar"
#define CHEAT_AUTORUN_LEVEL_LOOP		@"arll"
#define CHEAT_AUTORUN_GAME_LOOP			@"argl"
#define	CHEAT_AUTORUN_ACCUMULATE_SCORE	@"aras"

#define	CHEAT_ENABLE_ALL_LEVELS			@"eal"

#define	CHEAT_REPEAT_WORDS_IN_LEVEL		@"rwil"
#define CHEAT_PLAY_PAUSE_AT_WILL		@"ppaw"
#define CHEAT_SHOW_HINTS_AT_WILL		@"shaw"

#define CHEAT_LEVEL_END_MENU			@"lem"

#define	CHEAT_SPEAK_LETTER_SPELLING		@"sls"

#define	CHEAT_TEXT_HINT_MODE_1			@"thm1"
#define	CHEAT_TEXT_HINT_MODE_2			@"thm2"

#define	CHEAT_DISABLE_ALL_DECORATIONS	@"dad"

#define	CHEAT_USE_APPLE_STORE_ALWAYS	@"ufsa"
#define	CHEAT_USE_FREE_STORE_ALWAYS		@"uasa"

#define CHEAT_HAS_DEVELOPER_CREDENTIALS	@"hdc"
#define CHEAT_PURCHASE_RECORD_BROWSER	@"prb"
#define	CHEAT_FILE_SYSTEM_BROWSER		@"fsb"
#define	CHEAT_ALLOW_GAMETYPE_SELECTION	@"agts"
#define	CHEAT_ALLOW_CATALOG_SELECTION	@"acs"
#define	CHEAT_RESET_TO_FACTORY_SETTINGS	@"rtfs"
#define	CHEAT_IGNORE_DOWNLOAD_VERSIONS	@"idv"

#define	CHEAT_ALLOW_HAL_ACCESS			@"aha"

#define	CHEAT_ALLOW_MAGAZINE_SELECTION	@"ams"

#define	CHEAT_RC0_DIRECTORY				@"rc0d"


@end
