//
//  ViewController.m
//  SpellMaze2020
//
//  Created by Dror Kessler on 31/03/2020.
//  Copyright © 2020 Dror Kessler. All rights reserved.
//

#import "ViewController.h"

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

UINavigationController *_navigationController;
MainMenuWidget*        _mainMenu;

@interface ViewController ()

@end

@interface ViewController (Privates)
-(void)slideView:(UIView*)currentView toNextView:(UIView*)nextView;
-(void)slideViewBack:(UIView*)currentView toNextView:(UIView*)nextView;
-(void)confBrandDependencies;
@end


@implementation ViewController

@synthesize navigationController = _navigationController;
@synthesize mainMenu = _mainMenu;

-(void)dealloc
{
    [_navigationController release];
    [_mainMenu release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    MainMenuViewController*    rootViewController = [[[MainMenuViewController alloc] init] autorelease];
    
    UINavigationController    *aNavigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    self.navigationController = aNavigationController;
    
    [self confBrandDependencies];
    [[BrandManager singleton] addDelegate:self];

    [self.view addSubview:[aNavigationController view]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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
