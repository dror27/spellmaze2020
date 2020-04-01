//
//  PrefSaveAsProgrammableActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefSaveAsProgrammableActionItem.h"
#import "Folders.h"
#import "GameManager.h"


@implementation PrefSaveAsProgrammableActionItem

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

	// generate a new uuid
	NSString*	newUUID = [self createUUID];
	NSLog(@"newUUID: %@", newUUID);

	// establish target folder
	NSString*	newFolder = [[Folders roleFolder:FolderRoleCurrentGame forDomain:DF_LEVELS] stringByAppendingPathComponent:newUUID];
	NSLog(@"newFolder: %@", newFolder);

	// copy all files from source folder to target folder
	[Folders copyFolder:folder toFolder:newFolder];
	NSLog(@"folder copied");

	// get new props
	NSString*	name = [UserPrefs getString:[guuid stringByAppendingPathComponent:@"lm_level_name"] withDefault:@"Name"];
	NSLog(@"name: %@", name);
	NSString*	description = [UserPrefs getString:[guuid stringByAppendingPathComponent:@"lm_level_desc"] withDefault:@"Description"];
	NSLog(@"description: %@", description);

	// change level properties
	NSMutableDictionary*	props = [Folders getMutableFolderProps:newFolder];
	[props setObject:name forKey: @"name"];
	[props setObject:description forKey: @"description"];
	[Folders setProps:props forFolder:newFolder];
	NSLog(@"level props saved");

	// copy level preferences
	NSArray*				keys = [UserPrefs listKeysWithPrefix: [uuid stringByAppendingString:@"/"]];
	for ( NSString* key in keys )
	{
		NSString*	newKey = [newUUID stringByAppendingPathComponent:[key substringFromIndex:37]];

		NSLog(@"newKey: %@", newKey);
		[UserPrefs copyKey:key toKey:newKey];
	}
	NSLog(@"preferences copied");

	// put level into game
	NSString*				gfolder = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES withUUID:guuid];
	NSLog(@"gfolder: %@", gfolder);
	NSMutableDictionary*	gprops = [Folders getMutableFolderProps: gfolder];
	NSMutableArray*			levels = [gprops objectForKey:@"levels"];
	
	[levels addObject:newUUID];
	[Folders setProps:gprops forFolder:gfolder];
	NSLog(@"level added to game");

	// clear related caches
	[Folders clearDomainCache:NULL];
	[GameManager clearCache];
	NSLog(@"domain/game-manager caches cleared");

	[self updateProgress:-1.0 withMessage:@"Saved"];
	return FALSE;
}


@end
