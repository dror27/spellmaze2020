//
//  MainMenuViewController.h
//  Board3
//
//  Created by Dror Kessler on 6/27/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SplashPanel.h"
#import "BrandManager.h"

@class MainMenuWidget;
@class PrefViewController;
@class PrefMainPageBuilder;
@interface MainMenuViewController : UIViewController<SplashPanelDelegate,BrandManagerDelegate> {

	MainMenuWidget*		_mainMenu;
	
	UILabel*			_copyrightLabel;
	UIImageView*		_backgroundImageView;
	
	PrefMainPageBuilder* _prefMainPageBuilder;
	PrefViewController*	_flipController;
}
@property (retain) MainMenuWidget* mainMenu;
@property (retain) UILabel* copyrightLabel;
@property (retain) UIImageView* backgroundImageView;
@property (retain) PrefMainPageBuilder* prefMainPageBuilder;
@property (retain) PrefViewController* flipController;



@end
