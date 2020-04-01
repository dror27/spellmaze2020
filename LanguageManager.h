//
//  LanguageManager.h
//  Board3
//
//  Created by Dror Kessler on 7/4/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Language.h"
#import "UserPrefs.h"


#define		LM_GAME_LEVELS		@"GameLevels"

#define		LM_DEFAULT_LANGUAGE @"65F30756-43F1-40EA-B8B8-F8699B933FBD"

@interface LanguageManager : NSObject<UserPrefsDelegate> {

}

+(void) startPrefetch;
+(id<Language>) getNamedLanguage:(NSString*)name;
+(NSDictionary*) getNamedLanguageProps:(NSString*)name;

/* obsolete
+(void)add:(id<Language>)language withName:(NSString*)name;
*/

+(void)clearLanguagesCache;
+(void)clearLanguagesCacheOf:(id<Language>)language;

+(id<Language>)tutorialLanguageFor:(id<Language>)language;
+(id<Language>)tutorialPageLanguageFor:(id<Language>)language withPage:(int)page outOfPages:(int)pages;


@end
