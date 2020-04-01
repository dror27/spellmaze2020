//
//  PrefStringItemViewController.h
//  Board3
//
//  Created by Dror Kessler on 8/2/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableTableViewCell.h"
#import "PrefItemViewControllerBase.h"

@class PrefStringItem;
@interface PrefStringItemViewController : PrefItemViewControllerBase<UITextFieldDelegate,EditableTableViewCellDelegate,UITextViewDelegate> {

	UITextField*			_textField;	
	UITextView*				_textView;
	
}
@property (retain) UITextField*	textField;
@property (retain) UITextView*	textView;

@property (readonly) PrefStringItem* typedItem;
@end
