//
//  HasView.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HasView

-(UIView*)viewWithFrame:(CGRect)frame;
-(UIView*)view;

@end
