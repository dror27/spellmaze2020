//
//  PrefStringItemViewController.m
//  Board3
//
//  Created by Dror Kessler on 8/2/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefStringItemViewController.h"
#import "PrefStringItem.h"
#import "Constants.h"
#import "CellTextField.h"
#import "CellTextView.h"


// the amount of vertical shift upwards keep the text field in view as the keyboard appears
#define kOFFSET_FOR_KEYBOARD					150.0

#define kTextFieldWidth							100.0	// initial width, but the table cell will dictact the actual width

// the duration of the animation for the view shift
#define kVerticalOffsetAnimationDuration		0.30

#define kUITextField_Section					0
#define kUITextField_Rounded_Custom_Section		1
#define kUITextField_Secure_Section				2

@interface PrefStringItemViewController (Privates)
-(UITextField*)createTextField;
-(UITextView*)createTextView;
@end


@implementation PrefStringItemViewController
@synthesize textField = _textField;
@synthesize textView = _textView;

-(void)dealloc
{
	[_textField release];
	[_textView release];
	
	[super dealloc];
}

-(PrefStringItem*)typedItem
{
	return (PrefStringItem*)_item;
}

- (void)loadView 
{
	[super loadView];
	
	if ( !self.typedItem.multiline )
		self.textField = [self createTextField];
	else
		self.textView = [self createTextView];
}

#pragma mark - UITableView delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int		rows = [super tableView:tableView numberOfRowsInSection:section];
	
	if ( rows < 0 )
		rows = 1;
	
	return rows;
}

- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row forSection:(NSInteger)section
{
	UITableViewCell*	cell = [super obtainTableCellForRow:row forSection:section];
	if ( cell )
		return cell;
	
	if ( !self.typedItem.multiline )
	{
		UITableViewCell*	cell = [_myTableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		
		if (cell == nil)
		{
			cell = [[[CellTextField alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextField_ID] autorelease];
			((CellTextField *)cell).delegate = self;	// so we can detect when cell editing starts
		}
				
		return cell;
	}
	else
	{
		UITableViewCell*	cell = [_myTableView dequeueReusableCellWithIdentifier:kCellTextView_ID];
		
		if (cell == nil)
		{
			cell = [[[CellTextView alloc] initWithFrame:CGRectZero reuseIdentifier:kCellTextView_ID] autorelease];
			//((CellTextView *)cell).delegate = self;	// so we can detect when cell editing starts
		}
		
		return cell;
	}
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell*	cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if ( cell )
		return cell;
	
	NSInteger		row = [indexPath row];
	
	cell = [self obtainTableCellForRow:row forSection:[indexPath section]];
	
	if ( !self.typedItem.multiline )
	{
		((CellTextField *)cell).view = _textField;
		((CellTextField *)cell).view.text =  self.typedItem.value;
	}
	else
	{
		((CellTextView *)cell).view = _textView;
		((CellTextView *)cell).view.text =  self.typedItem.value;		
	}
	
	return cell;
}

-(void)viewDidAppear:(BOOL)animated
{
	if ( _textField )
		[_textField becomeFirstResponder];
	if ( _textView )
		[_textView becomeFirstResponder];
		
}

- (UITextField *)createTextField
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *returnTextField = [[[UITextField alloc] initWithFrame:frame] autorelease];
    
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:17.0];
    returnTextField.placeholder = @"<enter text>";
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	returnTextField.keyboardType = self.typedItem.keyboardType;
	returnTextField.autocapitalizationType = self.typedItem.autocapitalizationType;
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return returnTextField;
}

- (UITextView *)createTextView
{
	CGRect frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
	
	UITextView*	textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont fontWithName:kFontName size:kTextViewFontSize];
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
	
	textView.returnKeyType = UIReturnKeyDefault;
	textView.keyboardType = self.typedItem.keyboardType;
	textView.autocapitalizationType = self.typedItem.autocapitalizationType;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return textView;
}

- (void)cellDidEndEditing:(EditableTableViewCell *)cell
{
	self.typedItem.value = ((CellTextField *)cell).view.text;
	[self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark UITextView delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	// provide my own Save button to dismiss the keyboard
	UIBarButtonItem* saveItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			   target:self action:@selector(saveAction:)] autorelease];
	self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)saveAction:(id)sender
{
	// finish typing text/dismiss the keyboard by removing it as the first responder
	//
	UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	
	[((CellTextView *)cell).view resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;	// this will remove the "save" button
	
	self.typedItem.value = ((CellTextView *)cell).view.text;
	[self.navigationController popViewControllerAnimated:TRUE];
}

@end
