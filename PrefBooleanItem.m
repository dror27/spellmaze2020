//
//  PrefSwitchItem.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefBooleanItem.h"
#import "UserPrefs.h"
#import "Constants.h"


@implementation PrefBooleanItem
@synthesize defaultValue = _defaultValue;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDefaultBooleanValue:(BOOL)defaultValue
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.defaultValue = defaultValue;
	}
	return self;
}

-(UIView*)control
{
	if ( !_control )
	{
		CGRect		frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
		UISwitch*	switchControl = [[[UISwitch alloc] initWithFrame:frame] autorelease];
		
		[switchControl addTarget:self action:@selector(valueChangedAction:) forControlEvents:UIControlEventValueChanged];
		switchControl.backgroundColor = [UIColor clearColor];
		switchControl.on = [UserPrefs getBoolean:self.key withDefault:self.defaultValue];
		
		self.control = switchControl;
	}
	
	return _control;
}

-(void)valueChangedAction:(id)sender
{
	UISwitch*	switchControl = (UISwitch*)_control;
	
	[UserPrefs setBoolean:self.key withValue:switchControl.on];
	[self wasChanged];
}

-(void)refresh
{
	if ( self.control )
		((UISwitch*)self.control).on = [UserPrefs getBoolean:self.key withDefault:self.defaultValue];
}
@end
