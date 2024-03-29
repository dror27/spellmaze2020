//
//  ViewController.h
//  SpellMaze2020
//
//  Created by Dror Kessler on 31/03/2020.
//  Copyright © 2020 Dror Kessler. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GridBoardView.h"
#import "BrandManager.h"

@class MainMenuWidget;
@interface ViewController : UIViewController<BrandManagerDelegate> {
    
    UINavigationController *_navigationController;
    
    MainMenuWidget*        _mainMenu;
    
}
+(CGFloat)adjWidth:(CGFloat)w;
#define AW(x) ([ViewController adjWidth:x])

@property (retain) UINavigationController* navigationController;
@property (retain) MainMenuWidget* mainMenu;
@end

