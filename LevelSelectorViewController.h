//
//  LevelSelectorViewController.h
//  Board3
//
//  Created by Dror Kessler on 6/29/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ItemSelectorWidget;
@interface LevelSelectorViewController : UIViewController {

	ItemSelectorWidget*		_itemSelector;
}
@property (retain) ItemSelectorWidget* itemSelector;

@end
