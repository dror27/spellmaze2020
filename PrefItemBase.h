//
//  PrefItemBase.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UILabel.h>
#import "UserPrefs.h"

@interface PrefItemBase : NSObject<NSCopying,UserPrefsDelegate> {

	NSString*	_label;
	NSString*	_key;
	UIView*		_control;
	
	UIViewController* _viewController;
	
	NSString*	_relatedKey;
	
	UILabel*	_labelLabel;
}
@property (retain) NSString* label;
@property (retain) NSString* key;
@property (retain) UIView* control;
@property (readonly) BOOL nests;
@property (readonly) BOOL selectable;
@property (readonly) float rowHeight;
@property (readonly) BOOL sourceLabel;
@property (readonly) BOOL startup;
@property (nonatomic,assign) UIViewController* viewController;
@property (retain) NSString* relatedKey;
@property (retain) UILabel* labelLabel;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key;
-(void)wasSelected:(UIViewController*)inController;
-(void)refresh;
-(void)appeared;
-(void)disappeared;
-(void)wasChanged;

@end
