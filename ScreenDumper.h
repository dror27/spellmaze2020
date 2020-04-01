//
//  ScreenDumper.h
//  Board3
//
//  Created by Dror Kessler on 8/23/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScreenDumper : UIView {

	int				_port;
	UIView*			_onView;
}
@property (retain) UIView* onView;

-(void)startOnPort:(int)port withView:(UIView*)view;

@end
