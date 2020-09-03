//
//  ScoresDatabase.m
//  Board3
//
//  Created by Dror Kessler on 9/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ScoresDatabase.h"
#import "GameLevel.h"
#import "UserPrefs.h"
#import "UUIDUtils.h"
#import "Folders.h"
#import "GameLevelSequence.h"
#import "GameLevel.h"

extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"ScoresDatabase_singleton"

#define	CURRENT_SCORE		[UserPrefs getInteger:PK_SCORE withDefault:0]
#define	FOLDER_UUID			@"C78F2205-A6C4-4E9D-B86E-A1D84AC9E017"
#define	SIZE_THRESHOLD		0x4000

//#define	DUMP



@interface ScoresDatabase (Privates)
-(int)calcBestGameScore:(GameLevelSequence*)seq onLanguage:(id<Language>)language;
@end


@implementation ScoresDatabase
@synthesize currentLevelUUID = _currentLevelUUID;
@synthesize reportFolder = _reportFolder;
@synthesize reportLogUUID = _reportLogUUID;
@synthesize scoreNumberFormatter = _scoreNumberFormatter;

+(ScoresDatabase*)singleton
{
	@synchronized ([ScoresDatabase class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[ScoresDatabase alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(id)init
{
	if ( self = [super init] )
	{
		// establish folder, create
		self.reportFolder = [[Folders roleFolder:FolderRoleDownload forDomain:DF_DYNAMIC] stringByAppendingPathComponent:FOLDER_UUID];
		[[NSFileManager defaultManager] createDirectoryAtPath:_reportFolder withIntermediateDirectories:TRUE attributes:nil error:NULL];
		
		// initial props
		NSMutableDictionary*	props = [Folders getMutableFolderProps:_reportFolder];
		if ( ![props objectForKey:@"name"] )
			[props setObject:@"ReportsLog" forKey:@"name"];
		[Folders setProps:props forUUID:FOLDER_UUID forDomain:DF_DYNAMIC withRoleSearchOrder:NULL];

		// formatter
		self.scoreNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		[_scoreNumberFormatter setGroupingSize:3];
		[_scoreNumberFormatter setGroupingSeparator:@","];
		[_scoreNumberFormatter setUsesGroupingSeparator:TRUE];
		
		
	}
	return self;
}

-(void)dealloc
{
	[_currentLevelUUID release];
	[_reportFolder release];
	[_reportLogUUID release];
	
	[super dealloc];
}

-(void)reportLevelStarted:(GameLevel*)level
{
#ifdef DUMP
	NSLog(@"[ScoresDatabase] reportLevelStarted, level %@ %@", [level uuid], [level title]);
#endif
	
	self.currentLevelUUID = [level uuid];
	_currentLevelStartScore = CURRENT_SCORE;
	_currentLevelStartedAt = time(NULL);
}

-(void)reportLevelPassed:(GameLevel*)level
{
#ifdef DUMP
	NSLog(@"[ScoresDatabase] reportLevelPassed, level %@ %@", [level uuid], [level title]);	
#endif
	
	int		score = [self reportLevelEvent:level withType:RT_PASSED];
	if ( score >= 0 )
	{
		NSString*	key;
		time_t		now = time(NULL);
		
		// accumulate on lang
		key = [NSString stringWithFormat:@"%@_%@", PK_SCORE, [[level language] uuid]];
		[UserPrefs setInteger:key withValue:([UserPrefs getInteger:key withDefault:0] + score)];

		// accumulate on seq, seq_lang
		key = [NSString stringWithFormat:@"%@_%@", PK_SCORE, [[level seq] uuid]];
		[UserPrefs setInteger:key withValue:([UserPrefs getInteger:key withDefault:0] + score)];
		key = [NSString stringWithFormat:@"%@_%@_%@", PK_SCORE, [[level seq] uuid], [[level language] uuid]];
		[UserPrefs setInteger:key withValue:([UserPrefs getInteger:key withDefault:0] + score)];
		
		// accumulate on level, level_lang
		key = [NSString stringWithFormat:@"%@_%@", PK_SCORE, [level uuid]];
		[UserPrefs setInteger:key withValue:([UserPrefs getInteger:key withDefault:0] + score)];
		key = [NSString stringWithFormat:@"%@_%@_%@", PK_SCORE, [level uuid], [[level language] uuid]];
		[UserPrefs setInteger:key withValue:([UserPrefs getInteger:key withDefault:0] + score)];

		// update max on level, level_lang
		key = [NSString stringWithFormat:@"%@_%@_max", PK_SCORE, [level uuid]];
		if ( score > [UserPrefs getInteger:key withDefault:0] )
		{
			[UserPrefs setInteger:key withValue:score];
			[UserPrefs setInteger:[key stringByAppendingString:@"_when"] withValue:now];
		}	
		key = [NSString stringWithFormat:@"%@_%@_%@_max", PK_SCORE, [level uuid], [[level language] uuid]];
		if ( score > [UserPrefs getInteger:key withDefault:0] )
		{
			[UserPrefs setInteger:key withValue:score];
			[UserPrefs setInteger:[key stringByAppendingString:@"_when"] withValue:now];
		}	
		
		// update best score on seq, seq_lang
		key = [NSString stringWithFormat:@"%@_%@_best", PK_SCORE, [[level seq] uuid]];
		[UserPrefs setInteger:key withValue:[self calcBestGameScore:[level seq] onLanguage:NULL]];
		key = [NSString stringWithFormat:@"%@_%@_%@_best", PK_SCORE, [[level seq] uuid], [[level language] uuid]];
		[UserPrefs setInteger:key withValue:[self calcBestGameScore:[level seq] onLanguage:[level language]]];
	}
}

-(void)reportLevelFailed:(GameLevel*)level
{
#ifdef DUMP
	NSLog(@"[ScoresDatabase] reportLevelFailed, level %@ %@", [level uuid], [level title]);
#endif

	[self reportLevelEvent:level withType:RT_FAILED];
}

-(void)reportLevelAbandoned:(GameLevel*)level
{
#ifdef DUMP
	NSLog(@"[ScoresDatabase] reportLevelAbandoned, level %@ %@", [level uuid], [level title]);
#endif
	
	[self reportLevelEvent:level withType:RT_ABORTED];
}

-(int)reportLevelEvent:(GameLevel*)level withType:(NSString*)type
{
	return [self reportLevelEvent:level withType:type withTimeDelta:time(NULL) - _currentLevelStartedAt];
}

-(int)reportLevelEvent:(GameLevel*)level withType:(NSString*)type withTimeDelta:(time_t)timeDelta;
{
	NSString*		report;
	int				scoreDelta = 0;
	
	if ( level == NULL )
	{
		report = [NSString stringWithFormat:@"%@,,,,%d,%d,0,0", type, time(NULL), timeDelta];
	}
	else
	{	
		// must be on the same level
		if ( ![[level uuid] isEqualToString:_currentLevelUUID] )
			return -1;
		
		// calculate delta
		scoreDelta = CURRENT_SCORE - _currentLevelStartScore;

		// build event report
		// type,levelUUID,seqUUID,langUUID,scoreStart,scoreDelta,timeStart,timeDelta
		report = [NSString stringWithFormat:@"%@,%@,%@,%@,%d,%d,%d,%d", type, [level uuid],
							  [[level seq] uuid], [[level language] uuid], 
								_currentLevelStartedAt, timeDelta,
							  _currentLevelStartScore, scoreDelta];
	}
#ifdef DUMP
	NSLog(@"reportLevelEvent: %@", report);
#endif
	[self storeReport:report];
	
	return scoreDelta;
}

-(void)storeReport:(NSString*)report
{
	@synchronized (self)
	{
		NSString*		path;
		
		// start a new report log?
		if ( !_reportLogUUID )
		{
			// initialize new file
			self.reportLogUUID = [UUIDUtils createUUID];
			path = [self pathForReportLog:_reportLogUUID];
			
			// write header
			NSMutableString*	header = [NSMutableString string];
			[header appendFormat:@"# identity,device,when\n"];
			[header appendFormat:@"%@,%@,%d\n", [UserPrefs userIdentity], [[UIDevice currentDevice] identifierForVendor], time(NULL)];
			[header appendFormat:@"# type,level,game,langugage,whenStart,whenDelta,scoreStart,scoreDelta\n"];

			[header writeToFile:path atomically:FALSE encoding:NSUTF8StringEncoding error:NULL];
		}
		else
			path = [self pathForReportLog:_reportLogUUID];
#ifdef DUMP
		NSLog(@"path: %@", path);
#endif

		// append report to log
		NSFileHandle*	handle = [NSFileHandle fileHandleForUpdatingAtPath:path];
		[handle seekToEndOfFile];
		[handle writeData:[report dataUsingEncoding:NSUTF8StringEncoding]];
		[handle writeData:[@"\n"dataUsingEncoding:NSUTF8StringEncoding]];			
		unsigned long long ofs = [handle offsetInFile];
		[handle closeFile];
		
		// enough with this file?
		if ( ofs > (unsigned long long)SIZE_THRESHOLD )
			self.reportLogUUID = NULL;
	}
}

-(NSString*)oldestReportLog
{
	// if currently has an open file, close it ...
	@synchronized (self)
	{
		if ( _reportLogUUID )
			self.reportLogUUID = NULL;
	}
		
	NSFileManager*		fileManager = [NSFileManager defaultManager];
	NSError*			error;
	for ( NSString* content in [fileManager contentsOfDirectoryAtPath:_reportFolder error:&error] )
	{
		// for now, we take the first one we find ...
		if ( [content hasSuffix:@".txt"] && [content length] == 40 )
			return [content substringToIndex:36];
	}

	return NULL;
}

-(NSString*)pathForReportLog:(NSString*)reportLog
{
	return [[_reportFolder stringByAppendingPathComponent:reportLog] stringByAppendingPathExtension:@"txt"];
}

-(int)globalScore
{
	return [UserPrefs getInteger:PK_SCORE withDefault:0];
}

-(int)scoreForLanguage:(NSString*)language
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@", PK_SCORE, language];
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)scoreForGame:(NSString*)seq
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@", PK_SCORE, seq];
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)scoreForGame:(NSString*)seq onLanguage:(NSString*)language
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@_%@", PK_SCORE, seq, language];

	return [UserPrefs getInteger:key withDefault:0];
}

-(int)bestScoreForGame:(NSString*)seq
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@_best", PK_SCORE, seq];
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)bestScoreForGame:(NSString*)seq onLanguage:(NSString*)language
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@_%@_best", PK_SCORE, seq, language];
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)scoreForLevel:(NSString*)level
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@", PK_SCORE, level];	

	return [UserPrefs getInteger:key withDefault:0];
}

-(int)scoreForLevel:(NSString*)level onLanguage:(NSString*)language
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@_%@", PK_SCORE, level, language];
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)maxScoreForLevel:(NSString*)level
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@_max", PK_SCORE, level];	
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)maxScoreForLevel:(NSString*)level onLanguage:(NSString*)language
{
	NSString*		key = [NSString stringWithFormat:@"%@_%@_%@_max", PK_SCORE, level, language];
	
	return [UserPrefs getInteger:key withDefault:0];
}

-(int)calcBestGameScore:(GameLevelSequence*)seq onLanguage:(id<Language>)language
{
	int			score = 0;
	NSString*	langUUID = language ? [language uuid] : NULL;
	
	// best game score is the sum of the max scores in the game levels
	for ( NSString* level in [seq allLevelUUIDs] )
	{
		int		maxLevelScore = langUUID ? [self maxScoreForLevel:level onLanguage:langUUID]
										 : [self maxScoreForLevel:level];
		
		score += maxLevelScore;
	}
	
	return score;
}
@end
