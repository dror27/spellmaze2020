//
//  GameLevelSequence.m
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GameLevelSequence.h"
#import "GameLevel.h"
#import "UserPrefs.h"
#import "SystemUtils.h"
#import "ScoresDatabase.h"
#import "LanguageManager.h"
#import "PassedLevelEndMenu.h"
#import "L.h"
#import "SplashPanel.h"

#define	OP_NEXT_LEVEL		1
#define	OP_REPEAT_LEVEL		2
#define OP_STOP_PLAYING		3

@interface GameLevelSequence (Privates)
-(void)startCurrentLevel:(BOOL)continueCurrent;
-(void)discardCurrentLevel;
@end



@implementation GameLevelSequence
@synthesize levels = _levels;
@synthesize level = _level;
@synthesize view = _view;
@synthesize title = _title;
@synthesize shortDescription = _shortDescription;
@synthesize eventsTarget = _eventsTarget;
@synthesize uuid = _uuid;
@synthesize language = _language;
@synthesize helpSplashPanel = _helpSplashPanel;
@synthesize failedSplashPanel = _failedSplashPanel;
@synthesize passedLevelEndMenu = _passedLevelEndMenu;
@synthesize props = _props;
@synthesize upl = _upl;

-(id)init
{
	if ( self = [super init] )
	{
		self.levels = [[[NSMutableArray alloc] init] autorelease];
		currentLevel = 0;
	}
	return self;
}

-(void)dealloc
{
	for ( id<GameLevelFactory> factory in _levels )
		[factory setSeq:nil];
	[_levels release];
	
	[_level setSeq:nil];
	[_level release];
	
	[_view setModel:nil];
	[_view release];
	
	[_title release];
	[_shortDescription release];
	[_uuid release];
	[_language release];
	
	[_helpSplashPanel setDelegate:nil];
	[_helpSplashPanel release];

    [_failedSplashPanel setDelegate:nil];
    [_failedSplashPanel release];

	[_passedLevelEndMenu setSeq:nil];
	[_passedLevelEndMenu release];
	
	[_props release];
	[_upl release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( _view == NULL )
		self.view = [[GameLevelSequenceView alloc] initWithFrame:frame andModel:self];
	return _view;
}

-(void)addLevel:(id<GameLevelFactory>)level
{
	[_levels addObject:level];
	
	// temp
	if ( !_title && [_levels count] == 1 )
		self.title = [[level createGameLevel] title]; 
	if ( !_shortDescription && [_levels count] == 1 )
		self.shortDescription = [[level createGameLevel] shortDescription];
}

-(void)start
{
	NSString*		lastLevelUUID = [UserPrefs getString:PK_LAST_LEVEL withDefault:@""];
	int				lastLevelIndex = -1;
	int				lastResortIndex = -1;
	
	// find first unpassed level
	for ( int index = 0 ; index < [_levels count] ; index++ )
	{
		GameLevel*	level = [self levelAtIndex:index];
		BOOL		enabled = [UserPrefs levelEnabled:[level uuid]];
		if ( !enabled )
			continue;
		
		if ( ![UserPrefs levelPassed:level] )
		{
			[self startLevel:index];
			return;
		}
		else
			lastResortIndex = index;
		
		if ( [[level uuid] isEqualToString:lastLevelUUID] )
			lastLevelIndex = index;
	}
	
	// if here, all enabled levels have been passed, try last played or last resort
	if ( lastLevelIndex >= 0 )
	{
		[self startLevel:lastLevelIndex];
		return;
	}
	if ( lastResortIndex >= 0 )
	{
		[self startLevel:lastResortIndex];
		return;
	}
	
	
	// if here, must start from first. make sure it is enabled!
	[self startLevel:0];
}

-(void)startLevel:(int)index
{
	currentLevel = index;
	[self discardCurrentLevel];	
	[self startCurrentLevel:FALSE];
}

-(void)startCurrentLevel:(BOOL)continueCurrent
{
	NSSet*		initialBlackList = NULL;
	if ( continueCurrent && _level )
		initialBlackList = [_level validSelectedWords];
	
	[self discardCurrentLevel];
	
	if ( languageInvalidated )
	{
		self.language = [LanguageManager getNamedLanguage:[_language uuid]];
		languageInvalidated = FALSE;
	}
	
	id<GameLevelFactory>	factory = [_levels objectAtIndex:currentLevel];
	
	self.level = [factory createGameLevel];
	_level.initialBlackList = initialBlackList;
	
	[_view addSubview:[_level viewWithFrame:[_view frame]]];
	[_level setEventsTarget:self];
	[UserPrefs setString:PK_LAST_LEVEL withValue:[_level uuid]];
	
	[_level performSelector:@selector(startGame) withObject:self afterDelay:0.4]; 
	[[ScoresDatabase singleton] reportLevelStarted:_level];
	
	if ( _eventsTarget )
		[_eventsTarget seq:self levelStarted:_level];
}

-(void)stop
{
	if ( _level )
	{
		GameLevelState	state = [_level state];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:_level selector:@selector(startGame) object:_level];
		[_level stopGame];

		if ( state == DISPENSER_DONE )
			[[ScoresDatabase singleton] reportLevelPassed:_level];
		else
			[[ScoresDatabase singleton] reportLevelAbandoned:_level];
		
		[self discardCurrentLevel];
	}
}

-(void)passedLevel:(GameLevel*)level withMessage:(NSString*)message andContext:(void*)context
{	
	if ( !context )
	{
		// mark as passed
		[UserPrefs setLevelPassed:level passed:TRUE];
		if ( [level languageWordCount] - [level validSelectedWordCount] <= 0 )
			[UserPrefs setLevelExhausted:level passed:TRUE];
		[[ScoresDatabase singleton] reportLevelPassed:level];	
	
		// show level end menu? (TEMP!! remove FALSE)
		if ( [SystemUtils autorun] )
		{
			if (  level.levelEndMenu && ([_level languageWordCount] - [_level validSelectedWordCount] > _level.levelEndContinueRemainingWordCountThreshold) )
				context = (void*)PassedLevelEndMenuContext_ContinueLevel;
			else if ( [SystemUtils autorunLevelLoop] )
				context = (void*)PassedLevelEndMenuContext_RepeatLevel;
			else
				context = (void*)PassedLevelEndMenuContext_NextLevel;
		}
		else if ( level.levelEndMenu )
		{
			self.passedLevelEndMenu = [[[PassedLevelEndMenu alloc] initWithGameLevel:level andGameLevelSequence:self] autorelease];
			
			[_passedLevelEndMenu show];
			return;
		}	
	}
	
	// open related levels 
	if ( [UserPrefs levelPassed:level] )
	{
		NSArray*	openLevels = [level.props objectForKey:@"open-levels"];
		if ( openLevels )
			for ( NSString* openLevel in openLevels )
				[UserPrefs setLevelEnabled:openLevel enabled:TRUE];
	}
	
	// process level end menu
	PassedLevelEndMenuContext		menuContext = (PassedLevelEndMenuContext)context;
	BOOL							continueCurrent = FALSE;
	if ( !context || (menuContext == PassedLevelEndMenuContext_NextLevel) )
	{
		currentLevel++;
		if ( currentLevel < [_levels count] )
		{
			GameLevel*	level = [self levelAtIndex:currentLevel];
			
			if ( level )
				[UserPrefs setLevelEnabled:[level uuid] enabled:TRUE];
		}		
	}
	else if ( menuContext == PassedLevelEndMenuContext_RepeatLevel )
	{
		
	}
	else if ( menuContext == PassedLevelEndMenuContext_ContinueLevel )
	{
		continueCurrent = TRUE;
	}
	else if ( menuContext == PassedLevelEndMenuContext_StopPlaying )
	{
		// skip to last ...
		currentLevel = [_levels count];
	}
	
	// do it
	if ( currentLevel < [_levels count] )
		[self startCurrentLevel:continueCurrent];
	else if ( [SystemUtils autorunGameLoop] )
		[self startLevel:0];
	else
	{
		[self discardCurrentLevel];
		if ( _eventsTarget )
			[_eventsTarget sequenceFinished];
	}	
}

-(void)failedLevel:(GameLevel*)level withMessage:(NSString*)message andContext:(void*)context
{
	[[ScoresDatabase singleton] reportLevelFailed:level];	
    
	// stay on same level
    if ( ![SystemUtils autorun] && message )
    {
        [_failedSplashPanel release];
        _failedSplashPanel = [[[SplashPanel alloc] init] autorelease];
        _failedSplashPanel.title = LOC(@"Level Failed");
        _failedSplashPanel.buttonText = LOC(@"OK");
        _failedSplashPanel.delegate = self;
        [_failedSplashPanel show];
    }
	else
        [self failedLevelBody];
}

-(void)abortedLevel:(GameLevel*)level;
{
	if ( _eventsTarget )
		[_eventsTarget sequenceFinished];
}

-(void)failedLevelBody
{
    if ( currentLevel < [_levels count] )
        [self startCurrentLevel:FALSE];
    else if ( [SystemUtils autorunGameLoop] )
        [self startLevel:0];
    else
    {
        [self discardCurrentLevel];
        if ( _eventsTarget )
            [_eventsTarget sequenceFinished];
    }
}

-(int)levelCount
{
	return [_levels count];
}

-(GameLevel*)levelAtIndex:(int)index
{
	GameLevel*	level;
	@try
	{
		// TDOD: implement caching of created levels	
		id<GameLevelFactory>	factory = [_levels objectAtIndex:index];
		
		level = [factory createGameLevel];
	}
	@catch (NSException* e)
	{
		NSLog(@"GameLevelSequence: levelAtIndex EXCEPTION: @%", e);
		
		level = [[[GameLevel alloc] init] autorelease];
	}
	
	return level;
}

-(NSArray*)allLevels
{
	int					levelCount = [self levelCount];
	NSMutableArray*		allLevels = [NSMutableArray array];
	
	for ( int index = 0 ; index < levelCount ; index++ )
		[allLevels addObject:[self levelAtIndex:index]];
	
	return allLevels;
}	

-(NSArray*)allLevelUUIDs
{
	int					levelCount = [self levelCount];
	NSMutableArray*		allLevelUUIDs = [NSMutableArray array];
	
	for ( int index = 0 ; index < levelCount ; index++ )
		[allLevelUUIDs addObject:[self levelUUIDAtIndex:index]];
	
	return allLevelUUIDs;
}	

-(NSString*)levelUUIDAtIndex:(int)index
{
	id<GameLevelFactory>	factory = [_levels objectAtIndex:index];
	
	return [factory uuid];
}

-(id<HasUUID>)findHasUUID:(NSString*)uuid1
{
	for ( id<GameLevelFactory> factory in _levels )
		if ( [uuid1 isEqualToString:[factory uuid]] )
			return factory;
		
	return NULL;
}

-(void)discardCurrentLevel
{
	if ( _level )
	{
		[[_level view] removeFromSuperview];
		self.level = NULL;
	}
}

-(void)invalidateLanguage
{
	languageInvalidated = TRUE;
}

-(int)indexOfHighestPassedLevel
{
	int			levelCount = [self levelCount];
	int			index = levelCount - 1;
	
	for ( ; index >= 0 ; index-- )
	{
		GameLevel*	level = [self levelAtIndex:index];
		
		if ( [UserPrefs levelPassed:level] )
			return index;
	}
	
	return index;
}

-(void)splashDidShow:(SplashPanel*)panel
{
    
}

-(void)splashDidFinish:(SplashPanel*)panel
{
    [self failedLevelBody];
}


@end
