//
//  GameLevelSequence.h
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HasView.h"
#import "GameLevelFactory.h"
#import "GameLevelSequenceView.h"
#import "GameLevelEventsTarget.h"
#import "GameLevelSequenceEventsTarget.h"
#import "Language.h"
#import "HasUUIDDirectory.h"
#import "SplashPanel.h"
#import "PassedLevelEndMenu.h"
#import "UserPrefsLayer.h"

@class GameLevel, GameLevelSequence;

@interface GameLevelSequence : NSObject<HasView,GameLevelEventsTarget,HasUUIDDirectory,SplashPanelDelegate> {

	NSMutableArray*		_levels;
	int					currentLevel;
	GameLevel*			_level;
	
	GameLevelSequenceView*		_view;		
	
	NSString*			_title;
	NSString*			_shortDescription;
	
	id<GameLevelSequenceEventsTarget> _eventsTarget;
	
	NSString*			_uuid;
	
	id<Language>		_language;
	BOOL				languageInvalidated;
	
	SplashPanel*		_helpSplashPanel;	
    SplashPanel*     _failedSplashPanel;

	PassedLevelEndMenu*	_passedLevelEndMenu;
	
	NSDictionary*		_props;
	id<UserPrefsLayer>	_upl;
}
@property (retain) NSMutableArray* levels;
@property (retain) GameLevel* level;
@property (retain) GameLevelSequenceView* view;
@property (retain) NSString* title;
@property (retain) NSString* shortDescription;
@property (nonatomic,assign) id<GameLevelSequenceEventsTarget> eventsTarget;
@property (retain) NSString* uuid;
@property (retain) id<Language> language;
@property (retain) SplashPanel* helpSplashPanel;
@property (retain) SplashPanel* failedSplashPanel;
@property (retain) PassedLevelEndMenu* passedLevelEndMenu;
@property (retain) NSDictionary* props;
@property (retain) id<UserPrefsLayer> upl;

-(void)addLevel:(id<GameLevelFactory>)level;
-(void)start;
-(void)startLevel:(int)index;
-(int)levelCount;
-(void)stop;
-(GameLevel*)levelAtIndex:(int)index;
-(NSArray*)allLevels;
-(NSArray*)allLevelUUIDs;
-(NSString*)levelUUIDAtIndex:(int)index;
-(void)invalidateLanguage;
-(int)indexOfHighestPassedLevel;
@end
