//
//  PrefSection.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PrefSection : NSObject {

	NSString*		_title;
	NSString*		_comment;
	NSArray*		_items;
	
	UILabel*			_commentLabel;
	UIViewController*	_viewController;
}
@property (retain) NSString* title;
@property (retain) NSString* comment;
@property (retain) NSArray* items;
@property (retain) UILabel* commentLabel;
@property (nonatomic,assign) UIViewController* viewController;

-(void)refresh;
-(void)appearedIn:(UIViewController*)viewController;
-(void)disappeared;

@end
