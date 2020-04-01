//
//  PrefDeleteProgrammableActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefDeleteProgrammableActionItem.h"
#import "Folders.h"
#import "GameManager.h"


@implementation PrefDeleteProgrammableActionItem

-(BOOL)runAction
{
	// establish game uuid
	NSString*	guuid = _uuid;
	NSLog(@"guuid: %@", guuid);
	
	// establish uuid of level we're working on
	NSString*	uuid = [UserPrefs getString:[guuid stringByAppendingPathComponent:@"lm_level_uuid"] withDefault:@""];
	NSLog(@"uuid: %@", uuid);
	if ( ![uuid length] ) 
	{
		[self updateProgress:-1.0 withMessage:@"Select Level"];
		return FALSE;
	}
	
	// establish source folder
	NSString*	folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LEVELS withUUID:uuid];
	NSLog(@"folder: %@", folder);
	
	// remove the folder
    [Folders removeFolder:folder];
    
	// remove from game
	NSString*				gfolder = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES withUUID:guuid];
	NSLog(@"gfolder: %@", gfolder);
	NSMutableDictionary*	gprops = [Folders getMutableFolderProps: gfolder];
	NSMutableArray*			levels = [gprops objectForKey:@"levels"];
	
	[levels removeObject:uuid];
	[Folders setProps:gprops forFolder:gfolder];
	NSLog(@"level removed from game");
	
	// clear related caches
	[Folders clearDomainCache:NULL];
	[GameManager clearCache];
	NSLog(@"domain/game-manager caches cleared");
	
	[self updateProgress:-1.0 withMessage:@"Deleted"];
	return FALSE;
}

@end
