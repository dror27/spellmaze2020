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

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    MainMenuViewController*    rootViewController = [[[MainMenuViewController alloc] init] autorelease];
    
    UINavigationController    *aNavigationController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    
    [self confBrandDependencies];
    [[BrandManager singleton] addDelegate:self];

    [self.view addSubview:[aNavigationController view]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
