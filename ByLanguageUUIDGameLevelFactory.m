#if SCRIPTING
//
//  ByLanguageUUIDGameLevelFactory.m
//  Board3
//
//  Created by Dror Kessler on 9/11/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ByLanguageUUIDGameLevelFactory.h"
#import "LanguageManager.h"
#import "Folders.h"
#import "GameManager.h"
#import "GameLevel.h"

@implementation ByLanguageUUIDGameLevelFactory
@synthesize language = _language;

-(id)initWithUUID:(NSString*)uuid
{
	id<Language>		language = [LanguageManager getNamedLanguage:uuid];
	
	NSDictionary*		props = [Folders findUUIDProps:NULL forDomain:DF_LANGUAGES withUUID:uuid];
	
	if ( [props objectForKey:@"game"] )
		self = [super initWithUUID:[props objectForKey:@"game"]];
	else if ( [props objectForKey:@"game-props"] )
		self = [self initWithProps:[props objectForKey:@"game-props"]];
	else
		self = [super initWithUUID:GM_DEFAULT_GAME];	
	if ( _uuid  )
		self.uuid = uuid;
	
	self.language = language;
	
	return self;
}

-(void)dealloc
{
	[_language release];
	
	[super dealloc];
}

-(GameLevel*)createGameLevel
{
	GameLevel*	level = [super createGameLevel];
	
	level.language = _language;
	
	return level;
}

@end
#endif
