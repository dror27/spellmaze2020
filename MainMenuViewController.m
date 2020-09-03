//
//  MainMenuViewController.m
//  Board3
//
//  Created by Dror Kessler on 6/27/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "MainMenuViewController.h"
#import "MainMenuWidget.h"
#import "LevelSelectorViewController.h"
#import "GameLevelSequenceViewController.h"
#import "ScoresViewController.h"
#import "PrefViewController.h"
#import "PrefMainPageBuilder.h"
#import "GameManager.h"
#import "Folders.h"
#import "SystemUtils.h"
#import "SplashPanel.h"
#import "BrandManager.h"
#import "SystemUtils.h"
#import "NSDictionary_TypedAccess.h"
#import "UserPrefs.h"
#import "GameLevelSequence.h"
#import "ScoresDatabase.h"
#import "GlobalDefs.h"
#import "L.h"
#include "ViewController.h"

@interface MainMenuViewController (Privates)
-(void)doLevel:(id<HasView>)sender;
-(NSString*)buildTitle;
@end

extern NSMutableDictionary*	globalData;
extern time_t		appStartedAt;

@implementation MainMenuViewController
@synthesize mainMenu = _mainMenu;
@synthesize copyrightLabel = _copyrightLabel;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize prefMainPageBuilder = _prefMainPageBuilder;
@synthesize flipController = _flipController;


-(id)init
{
	if ( self = [super init] )
	{
		self.mainMenu = [[[MainMenuWidget alloc] init] autorelease];
		
		int					entryIndex;
		
		entryIndex = [_mainMenu addEntry:LOC_RTL(@"PLAY")];
		[_mainMenu setEntryAction:@selector(doPlay:) withTarget:self atIndex:entryIndex];
		
		entryIndex = [_mainMenu addEntry:LOC_RTL(@"LEVEL")];
		[_mainMenu setEntryAction:@selector(doLevel:) withTarget:self atIndex:entryIndex];
		
#if SHOW_SCORES
		entryIndex = [_mainMenu addEntry:LOC_RTL(@"SCORES")];
		[_mainMenu setEntryAction:@selector(doScores:) withTarget:self atIndex:entryIndex];
#else
        entryIndex = [_mainMenu addEntry:LOC_RTL(@"CONF")];
        [_mainMenu setEntryAction:@selector(flipAction2:) withTarget:self atIndex:entryIndex];
#endif
		
		[_mainMenu setPreferencesAction:@selector(flipAction:) withTarget:self];
		
		self.prefMainPageBuilder = [[[PrefMainPageBuilder alloc] init] autorelease];
		
		[globalData setObject:self.prefMainPageBuilder forKey:@"PrefMainPageBuilder_singleton"];
	}
	return self;
}

-(void)dealloc
{
	for ( int index = 0 ; index < [_mainMenu entryCount] ; index++ )
		[_mainMenu setEntryAction:nil withTarget:nil atIndex:index];
	[_mainMenu release];
	[_copyrightLabel release];
	[_backgroundImageView release];
	[_prefMainPageBuilder release];
	
	[_flipController setFlippedFrom:nil];
	[_flipController release];
	
	[super dealloc];
}

-(void)loadView
{
    // dump screen info
    UIScreen*    s = [UIScreen mainScreen];
    NSLog(@"bounds: %f,%f,%f,%f", s.bounds.origin.x, s.bounds.origin.y, s.bounds.size.width, s.bounds.size.height);
    NSLog(@"scale: %f", s.scale);
    NSLog(@"nativeBounds: %f,%f,%f,%f", s.nativeBounds.origin.x, s.nativeBounds.origin.y, s.nativeBounds.size.width, s.nativeBounds.size.height);
    NSLog(@"currentMode: %f,%f", s.currentMode.size.width, s.currentMode.size.height);

    
	// Create a custom view hierarchy.
	CGRect		frame =	[UIScreen mainScreen].bounds;
	frame.origin.y = FRAME_ORIGIN_Y_OFS;
	UIView		*view = [[[UIView alloc] initWithFrame:frame] autorelease];
	self.view = view;
    
	view.backgroundColor = [[BrandManager currentBrand] globalBackgroundColor];
    
	[[BrandManager singleton] addDelegate:self];
	
	self.backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background-menu" withDefaultValue:NULL];
	if ( !_backgroundImageView )
		self.backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background" withDefaultValue:NULL];
	if ( _backgroundImageView )
    {
        _backgroundImageView.frame = frame;
		[self.view addSubview:_backgroundImageView];
    }

    self.title = @"SpellMaze";
	
	[self.view addSubview:[_mainMenu viewWithFrame:[self.view frame]]];
	[_mainMenu paintEntries];
	
	

    CGRect		labelFrame = CGRectMake(35, [ViewController adjWidth:385] + FRAME_ORIGIN_Y_OFS + COPYRIGHT_Y_OFS, frame.size.width-70, 25);
	UILabel		*label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
	label.textColor = [[BrandManager currentBrand] globalTextColor];
	label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [[BrandManager currentBrand] globalDefaultFont:AW(12) bold:FALSE];
	label.text = @"Copyright © 2020 Dror Kessler";	
	label.alpha = 0.0;
	label.adjustsFontSizeToFitWidth = YES; 
	[self.view addSubview:label];
	self.copyrightLabel = label;

	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:2.0];
	label.alpha = 1.0;
	[UIView commitAnimations];	

	
	// check for expiration
	if ( [SystemUtils hasExpired] )
	{
		SplashPanel*		panel = [[SplashPanel alloc] init];
		NSDateFormatter*	dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		
		[dateFormatter setDateFormat:@"dd/MM/yy"];

		
		panel.title = @"Application Expired";
		panel.text = [NSString stringWithFormat:@"SpellMaze, Version %@, Build %@, has expired on %@. Please contact dror.kessler@gmail.com to renew your copy",
					  [SystemUtils softwareVersion],
					  [SystemUtils softwareBuild],
					  [dateFormatter stringFromDate:[SystemUtils expirationDate]]];
		panel.icon = [UIImage imageNamed:@"ProgramIcon1.png"];
		[panel.props setObject:@"expired" forKey:@"role"];
		panel.delegate = self;
		
		[panel show];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
	[_mainMenu reset];
	[_mainMenu appeared];
	
	if ( _flipController )
		[_flipController viewDidAppear:animated];
	else
		self.title = [self buildTitle];
}

-(void)viewWillAppear:(BOOL)animated
{
	[_mainMenu willAppear];

	if ( _flipController )
		[_flipController viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[_mainMenu disappeared];
	
	if ( _flipController )
		[_flipController viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
	if ( _flipController )
		[_flipController viewWillDisappear:animated];
	else
		self.title = @"SpellMaze";
}

-(void)doPlay:(id<HasView>)sender
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_PLAY withTimeDelta:time(NULL) - appStartedAt];
	
	[_mainMenu reset];
	
	
	GameLevelSequence*		seq = [GameManager currentGameLevelSequence];
	if ( ![GameManager gameReady:seq withSplashDelegate:self] )
		return;

	if ( [seq.props booleanForKey:@"show-levels-onces-on-play" withDefaultValue:FALSE] )
	{
		if ( ![UserPrefs getBoolean:[UserPrefs key:@"levels-menu-entered" forUuid:seq.uuid] withDefault:FALSE] )
		{
			[self doLevel:sender];
			return;
		}
	}
	
	
	UIViewController*		next = [[[GameLevelSequenceViewController alloc] init] autorelease];
	
	[self.navigationController pushViewController:next animated:TRUE];
}	

-(void)doLevel:(id<HasView>)sender
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_LEVELS withTimeDelta:time(NULL) - appStartedAt];
	
	[_mainMenu reset];
	
	GameLevelSequence*		seq = [GameManager currentGameLevelSequence];
	if ( ![GameManager gameReady:seq withSplashDelegate:self] )
		return;

	[UserPrefs setBoolean:[UserPrefs key:@"levels-menu-entered" forUuid:seq.uuid] withValue:TRUE];
	
	
	UIViewController*		next = [[[LevelSelectorViewController alloc] init] autorelease];
	
	[self.navigationController pushViewController:next animated:TRUE];
}	

-(void)doScores:(id<HasView>)sender
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_SCORES withTimeDelta:time(NULL) - appStartedAt];
	
	[_mainMenu reset];
	
	UIViewController*		next = [[[ScoresViewController alloc] init] autorelease];
	
	[self.navigationController pushViewController:next animated:TRUE];
}

-(void)flipAction2:(id)sender
{
    [self flipAction:sender autoGameSelection:FALSE];
}

-(void)flipAction:(id)sender
{
    [self flipAction:sender autoGameSelection:[sender isKindOfClass:[MainMenuWidget class]]];
}

-(void)flipAction:(id)sender autoGameSelection:(BOOL)autoGameSelection
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_MENU_PREFS withTimeDelta:time(NULL) - appStartedAt];

	if ( !_flipController )
		self.flipController = [[[PrefViewController alloc] initWithPrefPage:[_prefMainPageBuilder buildPrefPage] topPage:TRUE] autorelease];
	UIView		*flipView = [_flipController view];		
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.75];
	
	
    // checks to see if the view is attached
    [UIView setAnimationTransition:([flipView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:[self view] cache:YES];
    [UIView setAnimationTransition:([flipView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
						   forView:[[self navigationController] view] cache:YES];
    if ([flipView superview])
    {
        [flipView removeFromSuperview];
		//[[[self navigationItem] rightBarButtonItem] release];
        self.navigationItem.rightBarButtonItem = NULL;
		self.title = [self buildTitle];
		
		self.flipController = NULL;
		
		[_mainMenu willAppear];
		[_mainMenu appeared];
    }
    else
    {
        [[self view] addSubview:flipView];
        //[[[self navigationItem] rightBarButtonItem] release];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(flipAnimationDidStop:finished:context:)];
		self.title = LOC(@"Preferences");
		
		_flipController.flippedFrom = self;
		
		[_mainMenu reset];
		[_mainMenu disappeared];
		
		if ( autoGameSelection )
			[_flipController performSelector:@selector(autoGameSelection:) withObject:sender afterDelay:0.75];
    }
	
    [UIView commitAnimations];
	
#if 0
	[GameManager clearCache];
	[Folders clearDomainCache:NULL];
#endif
}

-(void)flipAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(LOC(@"Done"), nil) style:UIBarButtonItemStyleDone target:self action:@selector(flipAction:)] autorelease];
}

-(void)splashDidShow:(SplashPanel*)panel
{
}

-(void)splashDidFinish:(SplashPanel*)panel
{
	NSString*	role = [panel.props stringForKey:@"role" withDefaultValue:nil];

	panel.delegate = nil;
	
	if ( [role isEqualToString:@"update"] )
	{
		[panel autorelease];
		
		[self flipAction:self];
		[self performSelector:@selector(initiateDrillIntoLanguageKey:) withObject:self afterDelay:0.3];
	}
	else if ( [role isEqualToString:@"expired"] )
	{
		NSLog(@"Software has expired");
		exit(-1);
	}
}

-(void)initiateDrillIntoLanguageKey:(id)sender
{
	[_flipController drillIntoItemByKey:PK_LANG_DEFAULT];
}

-(void)brandDidChange:(Brand*)brand
{
	self.view.backgroundColor = [[BrandManager currentBrand] globalBackgroundColor];	

	if ( _backgroundImageView )
		[_backgroundImageView removeFromSuperview];
	self.backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background-menu" withDefaultValue:NULL];
	if ( !_backgroundImageView )
		self.backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background" withDefaultValue:NULL];
	if ( _backgroundImageView )
	{
		[self.view addSubview:_backgroundImageView];
		[self.view sendSubviewToBack:_backgroundImageView];
	}
	
	
	self.copyrightLabel.font = [[BrandManager currentBrand] globalDefaultFont:AW(12) bold:FALSE];
	self.copyrightLabel.textColor = [[BrandManager currentBrand] globalTextColor];
	
	
}

-(NSString*)buildTitle
{
	NSString*	gameTitle = [[GameManager currentGameLevelSequence] title];
	
	if ( [gameTitle length] )
	{
		if ( [gameTitle length] <= 17 )
			return [NSString stringWithFormat:@"SpellMaze - %@", gameTitle];
		else
			return gameTitle;

	}
	else
		return @"SpellMaze";
}

@end
