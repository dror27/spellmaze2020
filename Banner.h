//
//  Banner.h
//  Board3
//
//  Created by Dror Kessler on 9/10/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UITabBar.h>


@interface Banner : UIView {

	UIImageView* _imageView;
	NSString*	_link;	
}

@property (retain) UIImageView* imageView;
@property (retain) NSString* link;

-(void)placeOnView:(UIView*)view atY:(float)y;
-(void)removeFromView;

@end
