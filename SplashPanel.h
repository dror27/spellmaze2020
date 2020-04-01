//
//  SplashPanel.h
//  Board3
//
//  Created by Dror Kessler on 9/2/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SplashPanelView.h"
#import "HasUUID.h"

#define	ALERT_SPLASH

@class SplashPanel;
@protocol SplashPanelDelegate<NSObject>
-(void)splashDidShow:(SplashPanel*)panel;
-(void)splashDidFinish:(SplashPanel*)panel;
@end


@interface SplashPanel : NSObject<UIAlertViewDelegate> {

	NSString*				_title;
	NSString*				_text;
	UIImage*				_icon;
	id<SplashPanelDelegate>	_delegate;
	
	SplashPanelView*		_view;
	
	float					_width;
	float					_height;
	
	BOOL					_autoShow;
	
	double					_minShowTime;
	double					shownAt;
	
	float					textFontSize;
	
	UIAlertView*			_alertView;
	
	NSString*				_buttonText;
	
	NSMutableDictionary*	_props;
	
}
@property (retain) NSString* title;
@property (retain) NSString* text;
@property (retain) UIImage* icon;
@property (nonatomic,assign) id<SplashPanelDelegate> delegate;
@property (retain) SplashPanelView* view;
@property float width;
@property float height;
@property BOOL autoShow;
@property double minShowTime;
@property float textFontSize;
@property (retain) NSString* buttonText;
@property (retain) NSMutableDictionary* props;

@property (retain) UIAlertView* alertView;

-(void)show;
-(void)hide;
-(void)abort;
-(void)onTouched;
-(BOOL)shown;
-(void)toggle;

+(SplashPanel*)splashPanelWithProps:(NSDictionary*)props forUUID:(NSString*)uuid inDomain:(NSString*)domain
					   withDelegate:(id<SplashPanelDelegate>)delegate;


@end
