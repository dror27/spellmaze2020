//
//  Board3AppDelegate.h
//  Board3
//
//  Created by Dror Kessler on 4/29/09.
//  Copyright Dror Kessler (M) 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Board3ViewController;

@interface Board3AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow*				_window;
    Board3ViewController*	_viewController;
	
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Board3ViewController *viewController;

@end

