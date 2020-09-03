//
//  PrefStringItem.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefStringItem.h"
#import "UserPrefs.h"
#import "Constants.h"
#import "PrefStringItemViewController.h"
#import "L.h"
#import "RTLUtils.h"

// the amount of vertical shift upwards keep the text field in view as the keyboard appears
#define kOFFSET_FOR_KEYBOARD					150.0

#define kTextFieldWidth							100.0	// initial width, but the table cell will dictact the actual width

// the duration of the animation for the view shift
#define kVerticalOffsetAnimationDuration		0.30

#define kUITextField_Section					0
#define kUITextField_Rounded_Custom_Section		1
#define kUITextField_Secure_Section				2

@interface PrefStringItem (Privates)
-(NSString*)stringOrEmpty:(NSString*)s;
@end


@implementation PrefStringItem
@synthesize defaultValue = _defaultValue;
@synthesize keyboardType = _keyboardType;
@synthesize autocapitalizationType = _autocapitalizationType;
@synthesize multiline = _multiline;
@synthesize stringTransformer = _stringTransformer;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDefaultStringValue:(NSString*)defaultValue
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.defaultValue = defaultValue;
		self.value = [UserPrefs getString:self.key withDefault:self.defaultValue];
	}
	return self;
}

-(void)dealloc
{
	[_defaultValue release];
	[_value release];
	[_stringTransformer release];
	
	[super dealloc];
}

-(UIView*)control
{
	if ( !_control )
	{
		CGRect		frame = CGRectMake(0.0, 0.0, kMultiValueWidth, kMultiValueHeight);
		UILabel*	labelControl = [[[UILabel alloc] initWithFrame:frame] autorelease];
		
		labelControl.backgroundColor = [UIColor clearColor];
		labelControl.text = [self stringOrEmpty:self.value];
		labelControl.textAlignment = UITextAlignmentRight;
		labelControl.contentMode = UIViewContentModeCenter; 
		
		self.control = labelControl;
	}

	return _control;
}

-(BOOL)nests
{
	return TRUE;
}

-(NSString*)value
{
	return _value;
}

-(void)setValue:(NSString*)value;
{
	[_value autorelease];
	_value = [value retain];
	
	if ( self.control )
		[((UILabel*)self.control) setText:RTL([self stringOrEmpty:_value])];

	[UserPrefs setString:self.key withValue:value];
	[self wasChanged];
}

-(NSString*)stringOrEmpty:(NSString*)s
{
	if ( self.stringTransformer )
		s = [self.stringTransformer transformString:s];
	
	return (s && [s length]) ? s : LOC(@"<empty>");
}

-(void)wasSelected:(UIViewController*)inController
{
	PrefStringItemViewController	*next = [[[PrefStringItemViewController alloc] initWithItem:self] autorelease];
	
	if ( self.multiline )
		next.rowHeightIncrease = 2.5;
	
	[inController.navigationController pushViewController:next animated:TRUE];
}

-(void)refresh
{
	if ( self.control )
	{
		[_value autorelease];
		_value = [[UserPrefs getString:self.key withDefault:self.defaultValue] retain];

		[((UILabel*)self.control) setText:[self stringOrEmpty:_value]];	
	}
}


@end
