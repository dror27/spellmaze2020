//
//  PrefCreateIdentityActionItem.m
//  Board3
//
//  Created by Dror Kessler on 10/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefCreateIdentityActionItem.h"
#import "UserPrefs.h"
#import "L.h"

@implementation PrefCreateIdentityActionItem


-(void)wasSelected:(UIViewController*)inController
{
	NSString*	uuid = [UserPrefs createIdentity:[NSString stringWithFormat:LOC(@"Player%d"), [[UserPrefs allIdentities] count]]];
	
	[UserPrefs switchIdentity:uuid];
	
	[self reportDidFinish:NULL];
	
	[_viewController.navigationController popViewControllerAnimated:TRUE];
}

@end
