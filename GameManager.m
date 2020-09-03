//
//  GameManager.m
//  Board3
//
//  Created by Dror Kessler on 6/15/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GameManager.h"
#import "GameLevelSequence.h"
#import "ByScriptGameLevelFactory.h"
#import	"ByFolderGameLevelFactory.h"
#import "ByUUIDGameLevelFactory.h"
#import "UserPrefs.h"
#import "GameLevel.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"
#import "LanguageManager.h"
#import "ParametricGameLevelFactory.h"
#import "UUIDPropsUPL.h"
#import "L.h"

static BOOL					gameManager_initialized = FALSE;
static BOOL					gameManager_languageBased = TRUE;		// games are based on languages ... (otherwise ... old style)

#define						LANG_BASED (gameManager_languageBased)

extern NSMutableDictionary*	globalData;

@interface GameManager (Privates) 
+(id<UserPrefsLayer>)rebuildUPL:(GameLevelSequence*)seq;
@end


@implementation GameManager

+(NSString*)programUuid
{
	return PROGRAM_UUID;
}

+(GameLevelSequence*)currentGameLevelSequence
{
	@try
	{
		if ( !gameManager_initialized )
		{
			GameManager*		manager = [[GameManager alloc] init];	// this instance will linger forever
			[UserPrefs addKeyDelegate:manager forKey:PK_LEVEL_SET];
			[UserPrefs addKeyDelegate:manager forKey:PK_LANG_DEFAULT];
			gameManager_initialized = TRUE;
		}
		
		GameLevelSequence*		g_gameLevelSequence = [globalData objectForKey:@"g_gameLevelSequence"];
		if ( !g_gameLevelSequence )
		{
			NSString*		gameUUID = NULL;
			NSString*		gameFolder = NULL;
			NSDictionary*	gameProps = NULL;
			id<Language>	gameLanguage = NULL;
			NSDictionary*	langProps = NULL;
			
			if ( LANG_BASED )
			{
				gameLanguage = [LanguageManager getNamedLanguage:NULL];
				langProps = [Folders findUUIDProps:NULL forDomain:DF_LANGUAGES withUUID:[gameLanguage uuid]];
				
				if ( [langProps objectForKey:@"game"] )
				{
					// language specifies a game by references
					gameUUID = [langProps objectForKey:@"game"];
				}
				else if ( [langProps objectForKey:@"game-props"] )
				{
					// language specifies a game by value
					gameProps = [langProps objectForKey:@"game-props"];
					gameFolder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:[gameLanguage uuid]];
					gameUUID = [gameProps objectForKey:@"uuid"];
					if ( !gameUUID )
						gameUUID = [gameLanguage uuid];
				}
				else
				{
					// must use default game
					NSString*	langFolder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:[gameLanguage uuid]];
					BOOL		hasPictures = FALSE;
					if ( langFolder )
					{
						NSString*		imagesFolder = [langFolder stringByAppendingPathComponent:@"images"];
						NSFileManager	*fileManager = [NSFileManager defaultManager];
						if ( [fileManager fileExistsAtPath:imagesFolder] )
							hasPictures = TRUE;
					}
					gameUUID = [UserPrefs getString:PK_LEVEL_SET withDefault:!hasPictures ? GM_DEFAULT_GAME : GM_DEFAULT_GAME_PIC];
				}
				
			}
			else 
			{
				gameUUID = [UserPrefs getString:PK_LEVEL_SET withDefault:GM_DEFAULT_GAME];
			}
			if ( !gameFolder )
				gameFolder = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES withUUID:gameUUID];
			if ( !gameProps )
				gameProps = [Folders getMutableFolderProps:gameFolder];

			
			g_gameLevelSequence = [[[GameLevelSequence alloc] init] autorelease];
			g_gameLevelSequence.uuid = gameUUID;
			g_gameLevelSequence.title = [gameProps objectForKey:@"name"];
			g_gameLevelSequence.props = gameProps;

			
			if ( LANG_BASED )
			{
				g_gameLevelSequence.title = [langProps objectForKey:@"name"];
			}
					
			// setup language
			g_gameLevelSequence.language = [LanguageManager getNamedLanguage: NULL];
			g_gameLevelSequence.upl = [GameManager rebuildUPL:g_gameLevelSequence];
			g_gameLevelSequence.shortDescription = [g_gameLevelSequence.upl getString:@"description" withDefault:@""];
			g_gameLevelSequence.helpSplashPanel = [SplashPanel splashPanelWithProps:[g_gameLevelSequence.upl getObject:@"help-splash" withDefault:nil] 
																			forUUID:gameUUID inDomain:DF_GAMES withDelegate:NULL];
			
			BOOL			enableFirstLevel = TRUE;
			BOOL			enableAllLevels = [g_gameLevelSequence.upl getBoolean:@"all-levels-open" withDefault:FALSE];
			
			// loop over list of levels
			NSMutableArray*	roleSearchOrder = [NSMutableArray array];
			[roleSearchOrder addObject:[NSString stringWithFormat:@"%@:%@", DF_GAMES, gameUUID]];
			[roleSearchOrder addObjectsFromArray:[Folders defaultRoleSearchOrder]];
			for ( NSString* levelUUID in [g_gameLevelSequence.upl getObject:@"levels" withDefault:nil] )
			{
				NSMutableDictionary*				props = [Folders findUUIDProps:roleSearchOrder forDomain:DF_LEVELS withUUID:levelUUID];
				
				// fake props? better source them from the game props ...
				if ( ![props objectForKey:@"__baseFolder"] )
				{
					props = [g_gameLevelSequence.upl getObject:levelUUID withDefault:nil];
					if ( !props )
						props = [[[NSMutableDictionary alloc] init] autorelease];
					
					[props setObject:levelUUID forKey:@"uuid"];
					[props setObject:gameFolder forKey:@"__baseFolder"];
				}
				
				id<GameLevelFactory>		factory = NULL;
#if SCRIPTING
				if ( [props hasKey:@"script"] )
					factory = [[[ByUUIDGameLevelFactory alloc] initWithProps:props] autorelease];					
#endif
				if ( !factory )
					factory = [[[ParametricGameLevelFactory alloc] initWithProps:props] autorelease];
				
				[factory setProps:props];
				[factory setSeq:g_gameLevelSequence];
				[g_gameLevelSequence addLevel:factory];
			}
				
			// open first level
			if ( enableFirstLevel && [g_gameLevelSequence levelCount] > 0 )
			{
				[UserPrefs setLevelEnabled:[g_gameLevelSequence levelUUIDAtIndex:0] enabled:TRUE];
			}
			if ( enableAllLevels )
			{
				for ( int index = 0 ; index < [g_gameLevelSequence levelCount] ; index++ )
				{
					[UserPrefs setLevelEnabled:[g_gameLevelSequence levelUUIDAtIndex:index] enabled:TRUE];
				}
			}
			
			// open other levels
			for ( NSNumber* levelIndex in [g_gameLevelSequence.upl getObject:@"levels-open" withDefault:nil] )
				[UserPrefs setLevelEnabled:[g_gameLevelSequence levelUUIDAtIndex:[levelIndex intValue]] enabled:TRUE];
			
			[globalData setObject:g_gameLevelSequence forKey:@"g_gameLevelSequence"];
		}
	}
	@catch (NSException* e)
	{
		NSLog(@"GameManager: EXCEPTION: %@", e);
	}
	
	// still null? generate empty one
	if ( ![globalData objectForKey:@"g_gameLevelSequence"] )
	{
		[globalData setObject:[[[GameLevelSequence alloc] init] autorelease] forKey:@"g_gameLevelSequence"];
	}
	
	return [globalData objectForKey:@"g_gameLevelSequence"];
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	if ( [key isEqualToString:PK_LANG_DEFAULT] )
	{
		GameLevelSequence*		g_gameLevelSequence = [globalData objectForKey:@"g_gameLevelSequence"];
		if ( g_gameLevelSequence && ![g_gameLevelSequence.language.uuid isEqualToString:[UserPrefs getString:PK_LANG_DEFAULT withDefault:nil]] )
			[UserPrefs setString:PK_LANG_DEFAULT_PREV withValue:g_gameLevelSequence.language.uuid];
	}
	[GameManager clearCache];
}

+(void)clearCache
{
	[globalData removeObjectForKey:@"g_gameLevelSequence"];
}


+(BOOL)gameReady:(GameLevelSequence*)seq withSplashDelegate:(id<SplashPanelDelegate>)delegate
{
	NSDictionary*	langProps = [[seq language] props];
	int				updatedOn = [langProps integerForKey:@"updated-on" withDefaultValue:-1];
	if ( updatedOn != 0 )
		return TRUE;
	
	SplashPanel*	panel = [[SplashPanel alloc] init];
	panel.title = LOC(@"Game Not Ready");
	panel.text = LOC([langProps stringForKey:@"please-update-message" withDefaultValue:nil]);
	panel.buttonText = LOC(@"Update Now");
	[panel.props setObject:@"update" forKey:@"role"];
	panel.delegate = delegate;
	
	[panel show];
	
	return FALSE;
}

+(id<UserPrefsLayer>)rebuildUPL:(GameLevelSequence*)seq;
{
	id<UserPrefsLayer>		upl = [[[UUIDPropsUPL alloc] initWithUUID:nil andProps:seq.props andNextLayer:nil] autorelease];
	
	NSArray*				langLayers = [[seq.language props] objectForKey:@"game-props-layers"];
	if ( langLayers )
		for ( NSDictionary* layer in langLayers )
		{
			for ( NSString* key in [[layer stringForKey:@"key" withDefaultValue:@""] componentsSeparatedByString:@","] )
			{
				if ( [key isEqualToString:@"[Global]"] )
				{
					upl = [[[UUIDPropsUPL alloc] initWithUUID:nil andProps:[layer objectForKey:@"props"] andNextLayer:upl] autorelease];
				}
			}
		}
	
	return upl;
}

@end
