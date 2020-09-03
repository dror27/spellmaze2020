//
//  SplashPanelView.h
//  Board3
//
//  Created by Dror Kessler on 9/2/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

@class SplashPanel;
@interface SplashPanelView : UIView {

	SplashPanel*	_model;
	
	float			bottomAllocation;
	float			topAllocation;
}
@property (nonatomic,assign) SplashPanel* model;

-(id)initWithFrame:(CGRect)frame andModel:(SplashPanel*)model;

@end
