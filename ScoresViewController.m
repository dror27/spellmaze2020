//
//  ScoresViewController.m
//  Board3
//
//  Created by Dror Kessler on 7/14/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ScoresViewController.h"
#import "UserPrefs.h"
#import "GameManager.h"
#import "ScoreTableWidget.h"
#import "GameLevelSequence.h"
#import "BrandManager.h"
#import "ScoresComm.h"
#import "PullManager.h"
#import "SoundTheme.h"
#import "SystemUtils.h"
#import "GlobalDefs.h"
#import "L.h"

//#define	DUMP

@interface ScoresViewController (Privates)
-(void)fetchScores:(id)sender;
-(NSString*)buildSepRequestXML;
@end

#define			MAX_PULLS_PER_INITIAL_REQUEST		50

static BOOL		pulling = FALSE;

@implementation ScoresViewController
@synthesize scoreTable = _scoreTable;
@synthesize scoresComm = _scoresComm;
@synthesize soundTheme = _soundTheme;

-(id)init
{
	if ( self = [super init] )
	{
		self.scoresComm = [[[ScoresComm alloc] init] autorelease];
		self.soundTheme = [SoundTheme singleton];
	}
	return self;
}

-(void)dealloc
{
	[_scoreTable release];
	[_scoresComm release];
	[_soundTheme release];
	
	[super dealloc];
}

-(void)loadView
{
	// Create a custom view hierarchy.
	CGRect		frame =	[UIScreen mainScreen].bounds;
	frame.origin.y = FRAME_ORIGIN_Y_OFS;
	UIView		*view = [[[UIView alloc] initWithFrame:frame] autorelease];
	self.view = view;
	view.backgroundColor = [[BrandManager currentBrand] globalBackgroundColor];

	UIImageView*	backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background" withDefaultValue:NULL];
	if ( !backgroundImageView )
		backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background" withDefaultValue:NULL];
	if ( backgroundImageView )
		[self.view addSubview:backgroundImageView];
	
	self.title = LOC(@"Scores");
	
	self.scoreTable = [[[ScoreTableWidget alloc] init] autorelease];
	[self.view addSubview:[_scoreTable viewWithFrame:[self.view frame]]];
	[_scoreTable setPanelEventsTarget:self];
	
	// init with existing value?
	NSDictionary*		scores = [UserPrefs getDictionary:PK_NSEP_RESPONSE withDefault:NULL];
	if ( scores )
		[_scoreTable paintScores:scores];
	
	// fetch a new copy (on a different thread ...)
	[SystemUtils threadWithTarget:self selector:@selector(fetchScores:) object:NULL];
	//[NSThread detachNewThreadSelector:@selector(fetchScores:) toTarget:self withObject:NULL];
}

-(void)fetchScores:(id)sender
{
	NSAutoreleasePool*		pool = [[NSAutoreleasePool alloc] init];
	
	[[_scoreTable panel] performSelectorOnMainThread:@selector(setMessage1:) withObject:LOC(@"Loading ...") waitUntilDone:FALSE];
	[[_scoreTable panel] performSelectorOnMainThread:@selector(setMessage2:) withObject:@"" waitUntilDone:FALSE];
	
	NSDictionary*			scores = [_scoresComm fetchScoreRespose];
	
	if ( scores )
	{
		// save last received table (only if primary type)
		if ( [_scoresComm isOnFirstType] )
			[UserPrefs setDictionary:PK_NSEP_RESPONSE withValue:scores];

		// paint if not zombie
		if ( !zombie )
			[_scoreTable performSelectorOnMainThread:@selector(paintScores:) withObject:scores waitUntilDone:NO];
	}
	else
	{
		NSDictionary*		savedScores = [UserPrefs getDictionary:PK_NSEP_RESPONSE withDefault:NULL];
		if ( savedScores )
			[_scoreTable paintScores:savedScores];
	}

	[ScoresViewController executePullRequests:scores];
	
	[pool release];
}

+(BOOL)executePullRequestsWorthLaunching:(NSDictionary*)scores
{
	if ( !pulling && scores )
	{
		// print error?
		if ( [scores objectForKey:@"error"] )
			return FALSE;
		else
		{
			NSArray*				pullRequests = [scores objectForKey:@"pull-requests"];
			if ( pullRequests )
				return TRUE;
		}
	}
	return FALSE;
}

+(void)executePullRequests:(NSDictionary*)scores
{		
	if ( !pulling && scores )
	{
		pulling = TRUE;
		int		quotaLeft = MAX_PULLS_PER_INITIAL_REQUEST;
		
		// print error?
		if ( [scores objectForKey:@"error"] )
			NSLog(@"SEP SERVER ERROR: %@", [scores objectForKey:@"error"]);
		else
		{
			// execute pulls
			NSMutableArray*			queue = [NSMutableArray array];
			NSArray*				pullRequests = [scores objectForKey:@"pull-requests"];
			if ( pullRequests )
				[queue addObjectsFromArray:pullRequests];

			while ( [queue count]  && quotaLeft-- )
			{
				NSAutoreleasePool*		loopPool = [[NSAutoreleasePool alloc] init];
				
				NSDictionary*			pullRequest = [queue objectAtIndex:0];
				[queue removeObjectAtIndex:0];
				
				id<PullHandler>			pullHandler = [PullManager pullHandlerForRequest:pullRequest];
				if ( pullHandler )
					pullRequests = [[pullHandler push] retain]; // this retain is done to prevent the requests from being freeed by the inner pool (see #1)
				else
					pullRequests = NULL;
				
				[loopPool release];
				[pullRequests autorelease]; // #1 - complementing ...
				
				if ( pullRequests )
					[queue addObjectsFromArray:pullRequests];
			}
		
		}
		pulling = FALSE;
	}
}


-(void)viewDidAppear:(BOOL)animated
{
	[_scoreTable appeared];
}

-(void)viewDidDisappear:(BOOL)animated
{
	zombie = TRUE;
	[_scoreTable disappeared];
}

-(void)onScoreWidgetTouched:(int)tapCount
{
	if ( tapCount == 1 )
	{
		[_scoresComm advanceTypeToNext];
	
		[SystemUtils threadWithTarget:self selector:@selector(fetchScores:) object:NULL];
		//[NSThread detachNewThreadSelector:@selector(fetchScores:) toTarget:self withObject:NULL];
	}
}

-(SoundTheme*)soundTheme
{
	return _soundTheme;
}

@end
