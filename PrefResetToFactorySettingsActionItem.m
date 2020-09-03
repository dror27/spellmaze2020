//
//  PrefResetToFactorySettingsActionItem.m
//  Board3
//
//  Created by Dror Kessler on 8/15/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefResetToFactorySettingsActionItem.h"
#import "PrefThreadedActionItem.h"
#import "Folders.h"
#import "UserPrefs.h"


@implementation PrefResetToFactorySettingsActionItem

-(BOOL)runAction
{
	[self updateProgress:-1.0 withMessage:@"Reseting ..."];
	
	[Folders clearRoleFolder:FolderRoleDownload forDomain:NULL];
	[UserPrefs removeAll];

	[self updateProgress:-1.0 withMessage:@"Done"];

	[self performSelectorOnMainThread:@selector(reportDidFinish:) withObject:NULL waitUntilDone:FALSE];

	// does not linger ... (i.e. it ends here)
	return FALSE;
}

@end
