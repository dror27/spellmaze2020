//
//  Board3ViewController.h
//  Board3
//
//  Created by Dror Kessler on 4/29/09.
//  Copyright Dror Kessler (M) 2020. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GridBoardView.h"
#import "BrandManager.h"

@class MainMenuWidget;
@interface Board3ViewController : UIViewController<BrandManagerDelegate> {
	UINavigationController *_navigationController;
	
	MainMenuWidget*		_mainMenu;

}
@property (retain) UINavigationController* navigationController;
@property (retain) MainMenuWidget* mainMenu;

@end

