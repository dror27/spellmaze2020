//
//  PrefDeleteIdentityActionItem.m
//  Board3
//
//  Created by Dror Kessler on 10/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefDeleteIdentityActionItem.h"
#import <UIKit/UIKit.h>


@implementation PrefDeleteIdentityActionItem

-(void)wasSelected:(UIViewController*)inController
{
	NSString*	uuid = [UserPrefs userIdentity];
	
	[UserPrefs removeIdentity:uuid];
	
	[self reportDidFinish:NULL];
	
	[_viewController.navigationController popViewControllerAnimated:TRUE];
}


@end
