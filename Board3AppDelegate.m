//
//  Board3AppDelegate.m
//  Board3
//
//  Created by Dror Kessler on 4/29/09.
//  Copyright Dror Kessler (M-1) 2020. All rights reserved.
//

#import "Board3AppDelegate.h"
#import "Board3ViewController.h"
#import "GameLevelSequence.h"
#import "ByScriptGameLevelFactory.h"
#import "LanguageManager.h"
#import "ScreenDumper.h"
#import "BrandManager.h"
#import "StoreManager.h"
#import "Wallet.h"
#import "TextSpeaker.h"
#import "ScoresDatabase.h"


@implementation Board3AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;


BOOL		applicationResigned = FALSE;
time_t		appStartedAt;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	appStartedAt = time(NULL);
	
	// keep the splash just a bit longer ...
	//sleep(1);
	_window.backgroundColor = [UIColor blackColor];
	
	// put up startup image
	Brand*			brand = [BrandManager currentBrand];
	UIImage*		startupImage = [brand globalImage:@"startup" withDefaultValue:NULL];
	UIImageView*	startupImageView = NULL;
	BOOL			hasBrandStartupImage = startupImage != nil;
	if ( !startupImage )
		startupImage = [UIImage imageNamed:@"startup.png"];
	if ( startupImage )
	{
		CGRect		frame =	[UIScreen mainScreen].bounds;
		
		startupImageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
		
		startupImageView.image = startupImage;
		
        NSLog(@"v1 width: %f", _viewController.view.frame.size.width);
        [self.window setRootViewController:_viewController];
        NSLog(@"v1 width: %f", _viewController.view.frame.size.width);
        [_window addSubview:_viewController.view];
		[_window addSubview:startupImageView];
        
        NSLog(@"v1 width: %f", _viewController.view.frame.size.width);
        NSLog(@"v2 width: %f", startupImageView.frame.size.width);
        _viewController.view.frame = startupImageView.frame;
	}
#if 1
	[self performSelector:@selector(startup:) withObject:startupImageView afterDelay:(hasBrandStartupImage ? 2.0 : 2.0)];
#else
    [self startup:startupImageView];
#endif
}

-(void)startup:(UIImageView*)startupImageView
{
	_viewController.view.alpha = 0.0;
	
    // Override point for customization after app launch 
    [_window addSubview:_viewController.view];
    [_window makeKeyAndVisible];
	
	// start prefetch
	[LanguageManager startPrefetch];
	
	/*
	 [[[ScreenDumper alloc] init] startOnPort:9090 withView:viewController.view];
	 */
	
	if ( startupImageView )
	{
		[UIView beginAnimations:nil context:startupImageView];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(startupAnimationDidStop:finished:context:)];
		startupImageView.alpha = 0.0;
		[UIView commitAnimations];	
	}
	else
		_viewController.view.alpha = 1.0;
	
	
	// start store (queues, etc.)
	[StoreManager singleton];
	
#if 0

	NSLog(@"canMakePayments: %d", [[StoreManager singleton] canMakePayments]);
	[[StoreManager singleton] testRequestProductData:
				[NSSet setWithObjects:@"com.spellmaze.generic.test2", @"com.spellmaze.generic.test1", 
				 @"com.spellmaze.generic.com.spellmaze.generic.test2", @"com.spellmaze.generic.com.spellmaze.generic.test1", NULL]
				];
#endif
	
#if 0
	[[Wallet singleton] incrWalletItemValue:DECORATOR_DIGIT incr:1];
#endif
	
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_APP_STARTED withTimeDelta:time(NULL) - appStartedAt];
}

-(void)startupAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	UIImageView*	startupImageView = context;
	[startupImageView removeFromSuperview];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(startupAnimationDidStop2:finished:context:)];
	_viewController.view.alpha = 1.0;
	[UIView commitAnimations];	
}

-(void)startupAnimationDidStop2:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	_window.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc 
{
    [_viewController release];
    [_window release];
    
	[super dealloc];
}

-(void)applicationWillResignActive:(UIApplication *)application
{
	//NSLog(@"****** applicationWillResignActive");
	applicationResigned = TRUE;
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_APP_RESIGN_ACTIVE withTimeDelta:time(NULL) - appStartedAt];
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
	//NSLog(@"****** applicationDidBecomeActive");	
	applicationResigned = FALSE;
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_APP_BECAME_ACTIVE withTimeDelta:time(NULL) - appStartedAt];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
	//NSLog(@"****** applicationWillTerminate");	
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_APP_FINISHED withTimeDelta:time(NULL) - appStartedAt];
}
@end
