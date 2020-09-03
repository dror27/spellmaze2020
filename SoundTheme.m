//
//  SoundTheme.m
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "SoundTheme.h"
#import "TextSpeaker.h"
#import "UserPrefs.h"

extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"SoundTheme_singleton"


@interface Sound : NSObject
{
	SystemSoundID	ssid;
}
@property SystemSoundID ssid;
@end
@implementation Sound
@synthesize ssid;

-(void)dealloc
{
	if ( ssid )
		AudioServicesDisposeSystemSoundID(ssid);
	
	[super dealloc];
}
@end

@implementation SoundTheme
@synthesize speakValidWords;
@synthesize sounds = _sounds;
@synthesize notFound = _notFound;

-(id)init
{	
	if ( self = [super init] )
	{
		self.sounds = [[[NSMutableDictionary alloc] init] autorelease];
		self.notFound = [[[NSMutableSet alloc] init] autorelease];
		
		[self addSound:@"PieceSelected"];
		[self addSound:@"PieceDispensed"];
		[self addSound:@"PieceHinted"];
		[self addSound:@"PieceHintedLast"];
		[self addSound:@"WordValid"];
		[self addSound:@"WordInvalid"];
		[self addSound:@"WordBlackListed"];
		[self addSound:@"WordReset"];
		[self addSound:@"BoardFullWarning"];
		[self addSound:@"DispenserDoneWarning"];
		[self addSound:@"PassedLevel"];
		[self addSound:@"FailedLevel"];
		[self addSound:@"Clicked"];
		[self addSound:@"Swiped"];
		
		[self setSpeakValidWords:TRUE];
	}
	return self;
}

-(void)dealloc
{
	[_sounds release];
	[_notFound release];
	
	[super dealloc];
}

+(SoundTheme*)singleton
{
	@synchronized ([SoundTheme class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[SoundTheme alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(BOOL)enabled
{
	return [UserPrefs getBoolean:@"pref_sound_enabled" withDefault:TRUE];
}

-(void)addSound:(NSString*)name
{
	if ( [_notFound containsObject:name] )
		return;
	
	CFURLRef		soundFileURLRef;
	SystemSoundID	ssid = 0;
	
	NSString*		fullName = [NSString stringWithFormat:@"Sound_%@", name];
	
	soundFileURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)fullName, CFSTR("aif"), NULL);
	if ( soundFileURLRef )
	{
		AudioServicesCreateSystemSoundID(soundFileURLRef, &ssid);
		if ( ssid )
		{
			Sound*		sound = [[[Sound alloc] init] autorelease];
			[sound setSsid:ssid];
			[_sounds setObject:sound forKey:name];
		}
		CFRelease(soundFileURLRef);
	}
	else
		[_notFound addObject:name];
}

-(void)playSound:(NSString*)name
{
	if ( self.enabled )
	{
		Sound*			sound = [_sounds objectForKey:name];
		if ( !sound )
		{
			[self addSound:name];
			sound = [_sounds objectForKey:name];
		}
		if ( sound )
			AudioServicesPlaySystemSound([sound ssid]);	
	}
}


-(void)pieceSelected { [self playSound:@"PieceSelected"]; }
-(void)pieceDispensed {	[self playSound:@"PieceDispensed"]; }
-(void)pieceHinted {	[self playSound:@"PieceHinted"]; }
-(void)pieceHintedLast { [self playSound:@"PieceHintedLast"]; }

-(void)clicked { [self playSound:@"Clicked"]; }
-(void)swiped { [self playSound:@"Swiped"]; }


-(void)wordValid:(NSString*)word fromLanguage:(id<Language>)language
{ 
	if ( word && speakValidWords && [TextSpeaker enabled] )
	{
		NSURL*		wordSoundUrl = [language wordSoundUrl:word];

		if ( wordSoundUrl )
			[TextSpeaker play:wordSoundUrl];
		else 
		{
			NSString*	vl = [language voiceLanguage];
			if ( !vl )
				vl = TEXTSPEAKER_VOICE_DEFAULT_LANG;
			
			if ( [TextSpeaker speak:[NSArray arrayWithObjects: [language wordForHintWord:word], vl, NULL]] )
				return;
		}
	}
	[self playSound:@"WordValid"]; 
}
-(void)wordInvalid { [self playSound:@"WordInvalid"]; }
-(void)wordBlackListed { [self playSound:@"WordBlackListed"]; }
-(void)wordReset { [self playSound:@"WordReset"]; }
-(void)boardFullWarning { [self playSound:@"BoardFullWarning"]; }
-(void)dispenserDoneWarning { [self playSound:@"DispenserDoneWarning"]; }
-(void)passedLevel { [self playSound:@"PassedLevel"]; }
-(void)failedLevel { [self playSound:@"FailedLevel"]; }

-(void)decoration:(NSString*)decoration
{
	[self playSound:[NSString stringWithFormat: @"Decoration_%@", decoration]];
}

-(void)decorationExtra:(NSString*)decoration
{
	[self playSound:[NSString stringWithFormat: @"DecorationExtra_%@", decoration]];	
}


@end
