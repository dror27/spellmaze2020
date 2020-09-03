//
//  Board3ViewController.m
//  Board3
//
//  Created by Dror Kessler on 4/29/09.
//  Copyright Dror Kessler (M-1) 2020. All rights reserved.
//

#import "Board3ViewController.h"
#import "GameLevelSequence.h"
#import "MainMenuViewController.h"
#import "MainMenuWidget.h"
#import "GameManager.h"
#import "ItemSelectorWidget.h"
#import "TextSpeaker.h"
#import "StringsLanguage.h"
#import "LanguageManager.h"
#import "UserPrefs.h"
#import "BrandManager.h"

CGRect  globalFrame;

@interface Board3ViewController (Privates)
-(void)slideView:(UIView*)currentView toNextView:(UIView*)nextView;
-(void)slideViewBack:(UIView*)currentView toNextView:(UIView*)nextView;
-(void)confBrandDependencies;
@end

@implementation Board3ViewController
@synthesize navigationController = _navigationController;
@synthesize mainMenu = _mainMenu;



// The designated initializer. Override to perform setup that is required before the view is loaded.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
 */

-(void)dealloc
{
	[_navigationController release];
	[_mainMenu release];
	
	[super dealloc];
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	// Create a custom view hierarchy.
	CGRect		frame =	[UIScreen mainScreen].bounds;
	frame.origin.y = 0;
	UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
	view.autoresizesSubviews = YES;
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.view = view;
	
	MainMenuViewController*	rootViewController = [[[MainMenuViewController alloc] init] autorelease];
    
    /*
    navigationbar = UINavigationBar(frame: CGRect(x: 0, y: startingYPos, width: self.view.bounds.width, height: 44));
    */

	UINavigationController	*aNavigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
	self.navigationController = aNavigationController;
	
	[self confBrandDependencies];
	[[BrandManager singleton] addDelegate:self];
		
	//aNavigationController.title = @"SpellMaze";
	
	// Configure and display the window
	[view addSubview:[_navigationController view]];
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

    int     startingYPos = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGRect   bounds = self.view.bounds;
    CGRect   rect = CGRectMake(bounds.origin.x, bounds.origin.y + startingYPos,
                              bounds.size.width, bounds.size.height - startingYPos);
    self.navigationController.view.frame = rect;
    
    globalFrame = rect;
}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

-(void)viewWillAppear:(BOOL)animated {
	
	[_navigationController viewWillAppear:animated];
	
	//NSLog(@"%@ viewWillAppear", self.title);
	
}

-(void)viewDidAppear:(BOOL)animated {
	
	[_navigationController viewDidAppear:animated];
	
	//NSLog(@"%@ viewDidAppear", self.title);
	
}

-(void)viewWillDisappear:(BOOL)animated {
	
	[_navigationController viewWillDisappear:animated];
	
	//NSLog(@"%@ viewWillDisappear", self.title);
	
}

-(void)viewDidDisappear:(BOOL)animated {
	
	[_navigationController viewDidDisappear:animated];
	
	//NSLog(@"%@ viewDidDisappear", self.title);
	
}

-(void)brandDidChange:(Brand*)brand
{
	[self confBrandDependencies];
}

-(void)confBrandDependencies
{
	if ( [[BrandManager currentBrand] globalBoolean:@"skin/props/dark-pref-button" withDefaultValue:FALSE] )
		[[self.navigationController navigationBar] setBarStyle:UIBarStyleDefault];
	else
		[[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackOpaque];
}

@end
