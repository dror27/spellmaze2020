//
//  ScoresComm.m
//  Board3
//
//  Created by Dror Kessler on 9/23/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ScoresComm.h"
#import "GameManager.h"
#import "UserPrefs.h"
#import "GameLevelSequence.h"
#import "SystemUtils.h"
#import "ScoresDatabase.h"
#import "L.h"

@interface ScoresComm (Private)
-(NSArray*)scoresTypeOrder;
@end


@implementation ScoresComm
@synthesize type = _type;

//#define		DUMP

-(id)init
{
	if ( self = [super init] )
	{
		self.type = [[self scoresTypeOrder] objectAtIndex:0];
	}
	return self;
}

-(void)dealloc
{
	[_type release];
	
	[super dealloc];
}

-(NSArray*)scoresTypeOrder
{
	NSArray*	order = [UserPrefs getArray:@"scores-order" withDefault:NULL];
	
	if ( !order )
		order = [NSArray arrayWithObjects:SCORES_TYPE_GAME, SCORES_TYPE_MY_GAME, SCORES_TYPE_GLOBAL, SCORES_TYPE_MY_GLOBAL, NULL];
	
	return order;
}

-(void)advanceTypeToNext
{
	NSArray*		order = [self scoresTypeOrder];
	int				index = [order indexOfObject:_type];
	
	if ( index >= 0 && index < [order count] - 1 )
		index++;
	else
		index = 0;
	
	self.type = [order objectAtIndex:index];
}

-(NSString*)getLocalizedTitleForType:(NSString*)type
{
	if ( [type rangeOfString:@"global"].length > 0 )
		return LOC(@"SpellMaze");
	else if ( [type rangeOfString:@"game"].length > 0 )
		return [[GameManager currentGameLevelSequence] title];
	else
		return @"";
}

-(NSString*)getLocalizedSubTitleForType:(NSString*)type
{
	NSArray*		order = [self scoresTypeOrder];
	int				index = [order indexOfObject:_type];
	NSString*		suffix = @"";

	if ( [type hasPrefix:@"my_"] )
		suffix = [NSString stringWithFormat:@" - %@", LOC(@"Your Scores")];
	else
		suffix = [NSString stringWithFormat:@" - %@", LOC(@"High Scores")];

	return [NSString stringWithFormat:@"%d/%d%@", index + 1, [order count], suffix];
}

-(BOOL)isOnFirstType
{
	NSArray*		order = [self scoresTypeOrder];
	int				index = [order indexOfObject:_type];
	
	return index == 0;
}

-(NSDictionary*)buildScoreRequest
{
	NSMutableDictionary*	scoresReq = [NSMutableDictionary dictionary];
	NSString*				game = [[GameManager currentGameLevelSequence] uuid];
	NSString*				language = [[[GameManager currentGameLevelSequence] language] uuid];
	ScoresDatabase*			sdb = [ScoresDatabase singleton];
	
	[scoresReq setObject:NSEP_VERSION forKey:@"version"];
	[scoresReq setObject:[GameManager programUuid] forKey:@"program"];
	[scoresReq setObject:game forKey:@"game"];
	[scoresReq setObject:[NSNumber numberWithInt:[[GameManager currentGameLevelSequence] indexOfHighestPassedLevel]] forKey:@"game-toplevel"];
	[scoresReq setObject:language forKey:@"language"];
	[scoresReq setObject:[[UIDevice currentDevice] identifierForVendor] forKey:@"device"];
	[scoresReq setObject:[UserPrefs userIdentity] forKey:@"identity"];
	[scoresReq setObject:[UserPrefs userNick] forKey:@"identity-nick"];
	[scoresReq setObject:[UserPrefs getString:@"pref_scoring_nickface" withDefault:@""] forKey:@"identity-icon"];
	[scoresReq setObject:[[NSLocale currentLocale] localeIdentifier] forKey:@"locale"];
	[scoresReq setObject:_type forKey:@"query-type"];
	
	NSMutableArray*			gamesScores = [NSMutableArray arrayWithObjects:
											[NSMutableDictionary dictionaryWithObjectsAndKeys:
											 @"global", @"type",
											 [NSNumber numberWithInt:[sdb globalScore]], @"score",
											 NULL],
										   [NSMutableDictionary dictionaryWithObjectsAndKeys:
											@"game", @"type",
											[NSNumber numberWithInt:[sdb bestScoreForGame:game]], @"score",
											NULL],
										   [NSMutableDictionary dictionaryWithObjectsAndKeys:
											@"language", @"type",
											[NSNumber numberWithInt:[sdb scoreForLanguage:language]], @"score",
											NULL],
										   [NSMutableDictionary dictionaryWithObjectsAndKeys:
											@"game_language", @"type",
											[NSNumber numberWithInt:[sdb bestScoreForGame:game onLanguage:language]], @"score",
											NULL],
										   NULL
										   ];
	[scoresReq setObject:gamesScores forKey:@"games-scores"];
	
	NSMutableDictionary*	deviceInfo = [NSMutableDictionary dictionary];
	UIDevice*				device = [UIDevice currentDevice];
	[deviceInfo setObject:[device name] forKey:@"name"];
	[deviceInfo setObject:[device systemName] forKey:@"system-name"];
	[deviceInfo setObject:[device systemVersion] forKey:@"system-version"];
	[deviceInfo setObject:[device model] forKey:@"model"];
	[deviceInfo setObject:[device localizedModel] forKey:@"localized-model"];
	[deviceInfo setObject:[SystemUtils softwareVersion] forKey:@"app-version"];
	[deviceInfo setObject:[SystemUtils softwareBuild] forKey:@"app-build"];
	[scoresReq setObject:deviceInfo forKey:@"device-info"];
	
	return scoresReq;
}

-(NSDictionary*)fetchScoreRespose
{
	// get text representation of score request
	NSString*				errorString = nil;
	NSData*					requestData = [NSPropertyListSerialization dataFromPropertyList:[self buildScoreRequest] 
																  format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
	if ( !requestData || errorString )
	{
		NSLog(@"ERROR - %@", errorString);
		return NULL;
	}
#ifdef	DUMP
	NSLog(@"[ScoresComm] request: \n%@", [[[NSString alloc] initWithBytes:[requestData bytes] length:[requestData length] encoding:NSUTF8StringEncoding] autorelease]);
#endif
	
	// build request
	NSMutableURLRequest*	request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:NSEP_URL, NSEP_VERSION]]] autorelease];	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:requestData];
	
	// send and get response
	NSURLResponse*			response;
	NSError*				error;
	NSPropertyListFormat	format;
	NSData*					responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if ( !responseData || error )
	{
		NSLog(@"ERROR - %@", error);
		return NULL;		
	}
#ifdef	DUMP
	NSLog(@"[ScoresComm] response: \n%@", [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding] autorelease]);
#endif
	NSMutableDictionary*	responseProps = [NSPropertyListSerialization propertyListFromData:responseData 
																  mutabilityOption:NSPropertyListMutableContainersAndLeaves 
																  format:&format
																  errorDescription:&errorString];
	if ( !responseProps || errorString )
	{
		NSLog(@"ERROR - %@", errorString);
		return NULL;		
	}
	
	[responseProps setObject:[self getLocalizedTitleForType:_type] forKey:@"title"];
	[responseProps setObject:[self getLocalizedSubTitleForType:_type] forKey:@"sub-title"];

	// return the response
	return responseProps;	
}

@end
