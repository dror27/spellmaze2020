//
//  PrefGameSelectionPageItem.m
//  Board3
//
//  Created by Dror Kessler on 8/31/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefGameSelectionPageItem.h"
#import "Folders.h"
#import "GameManager.h"
#import "LanguageManager.h"
#import "RTLUtils.h"

@interface PrefGameSelectionPageItem (Privates)
-(void)updateLabel;
@end


@implementation PrefGameSelectionPageItem
@synthesize gameKey = _gameKey;
@synthesize languageKey = _languageKey;
@synthesize labelFormat = _labelFormat;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andPage:(PrefPage*)page
		andGameKey:(NSString*)gameKey andLanguageKey:(NSString*)languageKey andLabelFormat:(NSString*)labelFormat
{
	if ( self = [super initWithLabel:label andKey:key andPage:page] )
	{
		self.gameKey = gameKey;
		self.languageKey = languageKey;
		self.labelFormat = labelFormat;
		
		[UserPrefs addKeyDelegate:self forKey:self.gameKey];
		[UserPrefs addKeyDelegate:self forKey:self.languageKey];
	}
	
	return self;
}

-(void)dealloc
{
	[_gameKey release];
	[_languageKey release];
	[_labelFormat release];
	
	[super dealloc];
}

-(UIView*)control
{
	UIView*		control = [super control];
	
	[self updateLabel];
	
	return control;
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	if ( [key isEqualToString:self.gameKey] || [key isEqualToString:self.languageKey] )
	{
		[self updateLabel];
		[self wasChanged];
	}
	else
		[super userPrefsKeyChanged:key];
}

-(void)updateLabel
{
	if ( _control )
	{
		NSString*		gameName = @"";
		NSString*		languageName = @"";
		
		// get game name
		NSString*		gameFolder = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES 
														withUUID:[UserPrefs getString:self.gameKey withDefault:GM_DEFAULT_GAME]];
		if ( gameFolder )
		{
			NSDictionary*	props = [Folders getMutableFolderProps:gameFolder];
			if ( props )
				gameName = [props objectForKey:@"name"];
		}

		// get language name
		NSString*		languageFolder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES 
												  withUUID:[UserPrefs getString:self.languageKey withDefault:LM_DEFAULT_LANGUAGE]];
		if ( languageFolder )
		{
			NSDictionary*	props = [Folders getMutableFolderProps:languageFolder];
			if ( props )
				languageName = [props objectForKey:@"name"];
		}
		
		// build new label
		NSString*		label = [NSString stringWithFormat:self.labelFormat, gameName, languageName];
		// set new label
		((UILabel*)_control).text = RTL(label);
	}
}

-(void)refresh
{
	[self updateLabel];
	
	[super refresh];
}



@end
