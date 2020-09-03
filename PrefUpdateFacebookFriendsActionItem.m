//
//  PrefUpdateFacebookFriendsActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/25/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefUpdateFacebookFriendsActionItem.h"
/*#import "FacebookConnect.h"*/
#import "LanguageManager.h"
#import "Folders.h"
#import "GameManager.h"


@implementation PrefUpdateFacebookFriendsActionItem

-(BOOL)runAction
{
#if 0
	// login
    if ( ![[FacebookConnect singleton] login] )
	{
		[self updateProgress:-1.0 withMessage:@"Login Failed"];
		return FALSE;
	}
	
	// make sure ontology is writable
	[Folders makeUUIDMutable:NULL forDomain:DF_LANGUAGES withUUID:_uuid];

	// update
    [[FacebookConnect singleton] updateFriendsOntology:_uuid withActionItem:self];
	[GameManager clearCache];
    
	// clear cache
    [LanguageManager clearLanguagesCache];
	
	// save updated-on date
	NSString*		folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:_uuid];
	if ( folder )
	{
		NSMutableDictionary*		props = [Folders getMutableFolderProps:folder];
		
		[props setObject:[NSNumber numberWithInt:time(NULL)] forKey:@"updated-on"];
		
		[Folders setProps:props forFolder:folder];
	}
	
	[self updateProgress:-1.0 withMessage:@"Updated"];
	
	if ( [_viewController respondsToSelector:@selector(refresh)] )
		[_viewController performSelector:@selector(refresh)];
	
#endif
	return FALSE;
}


@end
