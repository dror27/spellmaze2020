//
//  ScoresDatabase.h
//  Board3
//
//  Created by Dror Kessler on 9/23/09.
//  Copyright 2009 Dror Kessler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Language.h"

@class GameLevelSequence, GameLevel;
@interface ScoresDatabase : NSObject {
	
	NSString*		_currentLevelUUID;
	int				_currentLevelStartScore;
	time_t			_currentLevelStartedAt;

	NSString*		_reportFolder;
	NSString*		_reportLogUUID;
	
	NSNumberFormatter* _scoreNumberFormatter;
}
@property (retain) NSString* currentLevelUUID;
@property (retain) NSString* reportFolder;
@property (retain) NSString* reportLogUUID;
@property (retain) NSNumberFormatter* scoreNumberFormatter;

+(ScoresDatabase*)singleton;

-(void)reportLevelStarted:(GameLevel*)level;
-(void)reportLevelPassed:(GameLevel*)level;
-(void)reportLevelFailed:(GameLevel*)level;
-(void)reportLevelAbandoned:(GameLevel*)level;
-(int)reportLevelEvent:(GameLevel*)level withType:(NSString*)type;
-(int)reportLevelEvent:(GameLevel*)level withType:(NSString*)type withTimeDelta:(time_t)timeDelta;
-(void)storeReport:(NSString*)report;

-(NSString*)oldestReportLog;
-(NSString*)pathForReportLog:(NSString*)reportLog;

// all args UUIDs
-(int)globalScore;
-(int)scoreForLanguage:(NSString*)language;
-(int)scoreForGame:(NSString*)seq;
-(int)scoreForGame:(NSString*)seq onLanguage:(NSString*)language;
-(int)bestScoreForGame:(NSString*)seq;
-(int)bestScoreForGame:(NSString*)seq onLanguage:(NSString*)language;
-(int)scoreForLevel:(NSString*)level;
-(int)scoreForLevel:(NSString*)level onLanguage:(NSString*)language;
-(int)maxScoreForLevel:(NSString*)level;
-(int)maxScoreForLevel:(NSString*)level onLanguage:(NSString*)language;

// report types
#define	RT_PASSED				@"P"
#define	RT_FAILED				@"F"
#define	RT_ABORTED				@"A"

#define	RT_APP_STARTED			@"AS"
#define	RT_APP_FINISHED			@"AF"
#define	RT_APP_BECAME_ACTIVE	@"AA"
#define RT_APP_RESIGN_ACTIVE	@"AR"

#define RT_MENU_PLAY			@"MP"
#define RT_MENU_LEVELS			@"ML"
#define RT_MENU_SCORES			@"MS"
#define RT_MENU_PREFS			@"MP"
#define	RT_MENU_GAME1			@"MG1"
#define	RT_MENU_GAME2			@"MG2"
#define	RT_MENU_STORE			@"MS"

#define	RT_URL_DIR				@"UD"

#define	RT_PURCHASE_START		@"PS"
#define RT_PURCHASE_OK			@"PO"
#define	RT_PURCHASE_FAILED		@"PF"

#define	RT_DOWNLOAD_START		@"DS"
#define	RT_DOWNLOAD_OK			@"DO"
#define	RT_DOWNLOAD_FAILED		@"DF"

#define	RT_FACEBOOK_START		@"FS"
#define	RT_FACEBOOK_OK			@"FO"
#define	RT_FACEBOOK_FAILED		@"FF"

#define	RT_CHEAT_XXX			@"C_"




@end
