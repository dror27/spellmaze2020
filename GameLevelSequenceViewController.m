//
//  GameLevelSequenceViewController.m
//  Board3
//
//  Created by Dror Kessler on 6/29/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GameLevelSequenceViewController.h"
#import "GameManager.h"
#import "GameLevelSequence.h"
#import "BrandManager.h"
#import "GameLevel.h"
#import "GlobalDefs.h"
#import "L.h"
#import "RTLUtils.h"


@implementation GameLevelSequenceViewController
@synthesize seq = _seq;
@synthesize levelIndex;
@synthesize level = _level;

-(id)init
{
	if ( self = [super init] )
	{
		self.seq = [GameManager currentGameLevelSequence];
		[_seq setEventsTarget:self];
		levelIndex = -1;
		self.level = NULL;
	}
	return self;
}

-(void)dealloc
{
	[_seq setEventsTarget:nil];
	[_seq release];
	
	[_level release];
	
	[super dealloc];
}

-(void)loadView
{
	// Create a custom view hierarchy.
	CGRect		frame =	[UIScreen mainScreen].bounds;
	frame.origin.y = FRAME_ORIGIN_Y_OFS;
	UIView		*view = [[UIView alloc] initWithFrame:frame];
	self.view = view;
	view.backgroundColor = [[BrandManager currentBrand] globalBackgroundColor];

	UIImageView*	backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background-game" withDefaultValue:NULL withSizeFromView:view];
	if ( !backgroundImageView )
		backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background" withDefaultValue:NULL withSizeFromView:view];
	if ( backgroundImageView )
	{
		[self.view addSubview:backgroundImageView];
	}

	self.title = LOC(@"Play!");
		
	[self.view addSubview:[_seq viewWithFrame:[self.view frame]]];
	if ( levelIndex >= 0 )
		[_seq startLevel:levelIndex];
	else
		[_seq start];
}

-(void)sequenceFinished
{
	[self.navigationController popViewControllerAnimated:TRUE];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[_seq stop];

	self.level = NULL;
}

-(void)seq:(GameLevelSequence*)seq1 levelStarted:(GameLevel*)level
{
	self.title = RTL([seq1 title]);
	
	[self performSelector:@selector(setTitle:) withObject:RTL([level title]) afterDelay:4];
	
	self.level = level;
	
	if ( _level.helpSplashPanel )
	{
		UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithTitle:LOC(@"Help") 
																  style:UIBarButtonItemStyleBordered target:self action:@selector(helpAction:)] autorelease];
		self.navigationItem.rightBarButtonItem = item;
	}
	else
		self.navigationItem.rightBarButtonItem = NULL;
}

-(void)helpAction:(id)sender
{
	if ( _level.helpSplashPanel )
	{
		if ( ![_level.helpSplashPanel shown] )
			[_level showHelpSplash];
		else
			[_level.helpSplashPanel hide];
	}
}
@end
