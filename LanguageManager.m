//
//  LanguageManager.m
//  Board3
//
//  Created by Dror Kessler on 7/4/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "LanguageManager.h"
#import	"StringsLanguage.h"
#import "UserPrefs.h"
#import "Board3ViewController.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"
#import "UUIDPrefs.h"
#import "SystemUtils.h"

#define ADMIN_ONE_LANG_IN_MEMORY

#if 0
static void panic(NSString* msg, NSString* key)
{
    [UserPrefs removeByPrefix:key];
    NSLog(@"PANIC: %@", msg);
    exit(-1);
}
#endif



@interface LanguageManager (Privates)
+(id<Language>) getNamedLanguageInternal:(NSString*)name;
-(void) prefetch:(NSString*)name;
@end

extern NSMutableDictionary*	globalData;
#define						LANGUAGES_KEY		@"LanguageManager_languages"
#define						SINGLETON_KEY		@"LanguageManager_singleton"
static BOOL					inPrefetch = FALSE;



@implementation LanguageManager

+(LanguageManager*)singleton
{
	@synchronized ([LanguageManager class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[LanguageManager alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(void)dealloc
{
	[super dealloc];
}


-(void)prefetch:(NSString*)name
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];

#ifdef DUMP
	NSLog(@"[LanguageManager] starting prefetch");
#endif
	[LanguageManager getNamedLanguageInternal:name];
	inPrefetch = FALSE;
#ifdef DUMP
	NSLog(@"[LanguageManager] prefetch completed");
#endif	
	[pool release];
}

+(void)startPrefetch
{	
	if ( !inPrefetch )
	{
#ifdef DUMP
		NSLog(@"[LanguageManager] scheduling prefetch");
#endif		
		// queue prefetch on a seperate thread
		inPrefetch = TRUE;
		LanguageManager*		lm = [LanguageManager singleton];
		
		[SystemUtils threadWithTarget:lm selector:@selector(prefetch:) object:[UserPrefs getString:@"pref_default_language" withDefault:LM_DEFAULT_LANGUAGE]];
		//[NSThread detachNewThreadSelector:@selector(prefetch:) toTarget:lm 
		//						withObject:[UserPrefs getString:@"pref_default_language" withDefault:LM_DEFAULT_LANGUAGE]];
#ifdef DUMP
		NSLog(@"[LanguageManager] prefetch scheduled");
#endif
	}
}

+(id<Language>) getNamedLanguage:(NSString*)name
{
	if ( !name || ![name length])
		name = LM_GAME_LEVELS;

	if ( [name isEqualToString:LM_GAME_LEVELS] )
		name = [UserPrefs getString:PK_LANG_DEFAULT withDefault:LM_DEFAULT_LANGUAGE];
	
	while ( inPrefetch )
	{
		sleep(1);
#ifdef DUMP
		NSLog(@"[LanguageManager] waiting for prefetch to complete");
#endif
	}
	
	return [LanguageManager getNamedLanguageInternal:name];
}

+(NSDictionary*) getNamedLanguageProps:(NSString*)name
{
	if ( !name || ![name length] ) 
		name = LM_GAME_LEVELS;

	if ( [name isEqualToString:LM_GAME_LEVELS] )
		name = [UserPrefs getString:PK_LANG_DEFAULT withDefault:LM_DEFAULT_LANGUAGE];
	
	NSString*	folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:name];
	
	return [Folders getMutableFolderProps:folder];
}

+(id<Language>) getNamedLanguageInternal:(NSString*)name
{
	NSMutableDictionary*		languages = [globalData objectForKey:LANGUAGES_KEY];
	if ( !languages )
	{
		languages = [[[NSMutableDictionary alloc] init] autorelease];
		[globalData setObject:languages forKey:LANGUAGES_KEY];
	}

	
	if ( ![languages objectForKey:name] ) 
	{
		if ( [name isEqualToString:@"Custom"] || [name isEqualToString:@"687DEE42-E29D-419F-89F4-61F42E877CDA"] )
		{
			NSError*			error;
			NSURL*				url = [[[NSURL alloc] initWithString:[UserPrefs getString:PK_LANGUAGE_URL withDefault:NULL]] autorelease];
			NSString*			strings = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
			StringsLanguage*	l = [StringsLanguage alloc];
			l.uuid = @"687DEE42-E29D-419F-89F4-61F42E877CDA";
			l.splitWords = TRUE;
			l.allCaps = TRUE;
			l.name = @"Custom";
			l = [l initWithStringsString:strings];

#ifdef ADMIN_ONE_LANG_IN_MEMORY
			[languages removeAllObjects];
#endif
			[languages setObject:l forKey:name];

			[UserPrefs addKeyDelegate:[LanguageManager singleton] forKey:name];
			
		}
		else if ( [name length] == 36 )
		{
			// this is a crude way of saying that this is a uuid for the language ...
			NSString*			folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:name];
#if 0
			if ( !folder )
				panic([NSString stringWithFormat:@"Language folder not found: %@", name], PK_LANG_DEFAULT);
#endif
			NSString*			path = [folder stringByAppendingPathComponent:@"words.txt"];
			NSDictionary*		props = [Folders getMutableFolderProps:folder];
	
			StringsLanguage*	l = [StringsLanguage alloc];
			l.uuid = name;
			l.name = [props objectForKey:@"name"];
			l.splitWords = [props booleanForKey:@"split-words" withDefaultValue:FALSE];
			l.allCaps = [props booleanForKey:@"all-caps" withDefaultValue:TRUE];
			l.textDelimiter = [props stringForKey:@"text-delimiter" withDefaultValue:NULL];
			l.rtl = [props booleanForKey:@"rtl" withDefaultValue:FALSE];
			l.minWordLength = [props integerForKey:@"min-word-length" withDefaultValue:2];
			l.allowAddWord = [props booleanForKey:@"allow-add-word" withDefaultValue:TRUE];
			l.voiceLanguage = [props stringForKey:@"voice-language" withDefaultValue:NULL];
			l.props = props;
			
			// user properties?
			NSString*			words = [UserPrefs getExplicitString:[NSString stringWithFormat:@"%@/words", name] withDefault:NULL];
			if ( words )
			{
				l.splitWords = [UserPrefs getExplicitBoolean:[NSString stringWithFormat:@"%@/split-words", name] withDefault:TRUE];
				l.allCaps = [UserPrefs getExplicitBoolean:[NSString stringWithFormat:@"%@/all-caps", name] withDefault:TRUE];
				l.rtl = [UserPrefs getExplicitBoolean:[NSString stringWithFormat:@"%@/rtl", name] withDefault:FALSE];
				
				l = [l initWithStringsString:words];
			}
			else
				l = [l initWithStringsFile:path];
			
#ifdef ADMIN_ONE_LANG_IN_MEMORY
			[languages removeAllObjects];
#endif
			[languages setObject:l forKey:name];
			[UserPrefs addKeyDelegate:[LanguageManager singleton] forKey:name];
		}
	}
	
	return [languages objectForKey:name];
}

/* obsolete
+(void)add:(id<Language>)language withName:(NSString*)name
{
	while ( inPrefetch )
	{
		sleep(1);
#ifdef DUMP
		NSLog(@"[LanguageManager] waiting for prefetch to complete");
#endif
	}
	
	NSMutableDictionary*		languages = [globalData objectForKey:LANGUAGES_KEY];
	[languages setObject:language forKey:name];
}
*/

+(void)clearLanguagesCache
{
	@synchronized ([LanguageManager class])
	{
		NSMutableDictionary*		languages = [globalData objectForKey:LANGUAGES_KEY];
		if ( languages )
			[languages removeAllObjects];
	}
}

+(void)clearLanguagesCacheOf:(id<Language>)language
{
	@synchronized ([LanguageManager class])
	{
		NSMutableDictionary*		languages = [globalData objectForKey:LANGUAGES_KEY];
		if ( languages && [languages hasKey:[language uuid]] )
			[languages removeObjectForKey:[language uuid]];
	}
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	@synchronized ([LanguageManager class])
	{
		NSMutableDictionary*		languages = [globalData objectForKey:LANGUAGES_KEY];
		if ( languages && [languages hasKey:key] )
			[languages removeObjectForKey:key];
	}
}

+(NSString*)languageArchivePath:(NSString*)uuid
{
	return [[Folders findMutableUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:uuid] stringByAppendingPathComponent:@"language.archive"];
}

+(id<Language>)tutorialLanguageFor:(id<Language>)language
{
	NSArray*			words = NULL;
	
	// try to pick up words from the language's props
	NSString*			folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:[language uuid]];
	if ( folder )
	{
		NSDictionary*		props = [Folders getMutableFolderProps:folder];
		if ( props )
			words = [props arrayForKey:@"tutorial-words" withDefaultValue:NULL];
	}
	
	// must generate?
	if ( !words )
	{
		NSMutableArray*		tutorialWords = [[[NSMutableArray alloc] init] autorelease];
		int					maxLengths[] = {3, 4, 6, 4};
		int					tutorialWordsCount = sizeof(maxLengths) / sizeof(maxLengths[0]);
		for ( int index = 0 ; [tutorialWords count] < tutorialWordsCount && index < [language wordCount] ; index++ ) 
		{
			NSString*		word = [language getWordByIndex:index];
			int				lengthLimit = maxLengths[[tutorialWords count]];
			
			if ( [word length] > lengthLimit )
				continue;
			
			[tutorialWords addObject:word];
		}
		words = tutorialWords;
	}
	
	// if too small, just default to the first 4 words of the language
	if ( !words || [words count] < 4 )
	{
		int			maxIndex = MIN(4, [language wordCount]);
		NSMutableArray*		tutorialWords = [[[NSMutableArray alloc] init] autorelease];
		
		for ( int index = 0 ; index < maxIndex ; index++ )
			[tutorialWords addObject:[language getWordByIndex:index]];
			 
		words = tutorialWords;
	}
	
	// create a new language
	StringsLanguage*			l = [[[StringsLanguage alloc] initWithStringsArray:words] autorelease];
	[l setName:[language name]];
	[l setUuid:[language uuid]];
	[l setRtl:[language rtl]];
	[l setAllowAddWord:FALSE];
	[l setAllWordsOverride:words];
	[l setVoiceLanguage:[language voiceLanguage]];
	[l setWordsOrigin:[language wordsOrigin]];
	
	return l;
}

+(id<Language>)tutorialPageLanguageFor:(id<Language>)language withPage:(int)page outOfPages:(int)pages
{
	// fallback
	if ( page <= 0 || pages <= 0 )
		return [LanguageManager tutorialLanguageFor:language];
	page = MIN(page, pages);
	
	// establish word range
	int			wordCount = [language wordCount];
	double		pageSize = wordCount / pages;
	int			pageStart = round(pageSize * (page - 1));
	int			pageEnd = round(pageSize * page) - 1;

	// collect words
	NSMutableArray*		words = [[[NSMutableArray alloc] init] autorelease];
	for ( int index = pageStart ; index < pageEnd ; index++ )
		[words addObject:[language getWordByIndex:index]];
	
	// create a new language
	StringsLanguage*			l = [[[StringsLanguage alloc] initWithStringsArray:words] autorelease];
	[l setName:[language name]];
	[l setUuid:[language uuid]];
	[l setRtl:[language rtl]];
	[l setAllowAddWord:FALSE];
	[l setAllWordsOverride:words];
	[l setVoiceLanguage:[language voiceLanguage]];
	[l setWordsOrigin:[language wordsOrigin]];
	
	return l;	
}

@end
