//
//  PrefPageItem.m
//  Board3
//
//  Created by Dror Kessler on 8/3/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefPageItem.h"
#import "PrefPage.h"
#import "Constants.h"
#import "PrefViewController.h"
#import "PrefFileViewController.h"
#import "PrefPurchaseRecordViewController.h"
#import "PrefAbraViewController.h"

@implementation PrefPageItem
@synthesize page = _page;
@synthesize viewControllerClassName = _viewControllerClassName;
@synthesize viewControllerArgument = _viewControllerArgument;
@synthesize valueFieldWidthFactor;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andPage:(PrefPage*)page;
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.page = page;
		
		valueFieldWidthFactor = 1.0;
	}
	return self;
}

-(void)dealloc
{
	[_page release];
	[_viewControllerClassName release];
	[_viewControllerArgument release];
	
	[super dealloc];
}

-(UIView*)control
{
	if ( !_control )
	{
		CGRect		frame = CGRectMake(0.0, 0.0, kMultiValueWidth * valueFieldWidthFactor, kMultiValueHeight);
		UILabel*	labelControl = [[[UILabel alloc] initWithFrame:frame] autorelease];
		
		labelControl.backgroundColor = [UIColor clearColor];
		labelControl.text = @""; // summary could go here ...
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

-(void)wasSelected:(UIViewController*)inController
{
	UIViewController	*next = nil;
	
	if ( self.viewControllerClassName )
	{
		// TODO: remove dependency on explicit class names
		if ( [self.viewControllerClassName isEqualToString:@"PrefFileViewController"] )
			next = [[[PrefFileViewController alloc] initWithArgument:self.viewControllerArgument] autorelease];
		else if ( [self.viewControllerClassName isEqualToString:@"PrefPurchaseRecordViewController"] )
			next = [[[PrefPurchaseRecordViewController alloc] initWithArgument:self.viewControllerArgument] autorelease];
		else if ( [self.viewControllerClassName isEqualToString:@"PrefAbraViewController"] )
			next = [[[PrefAbraViewController alloc] initWithArgument:self.viewControllerArgument] autorelease];
	}
	if ( !next )
		next = [[[PrefViewController alloc] initWithPrefPage:self.page] autorelease];
	
	[inController.navigationController pushViewController:next animated:TRUE];
}

-(void)refresh
{
	[self.page refresh];
}

@end
