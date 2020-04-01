//
//  PrefAbraViewController.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PrefAbraViewController : UIViewController<UITextFieldDelegate> {

	UITextField*			_textField;	
	UITextView*				_textView;
	
	NSURL*					_url;
	NSString*				_sessionID;
	
}
@property (retain) UITextField*	textField;
@property (retain) UITextView*	textView;
@property (retain) NSURL*		url;
@property (retain) NSString*	sessionID;


-(id)initWithArgument:(NSObject*)initialQuestion;

@end
