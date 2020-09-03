//
//  PrefRenameProgrammableActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/26/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefRenameProgrammableActionItem.h"
#import "Folders.h"
#import "GameManager.h"


@implementation PrefRenameProgrammableActionItem

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
	
	// get new props
	NSString*	name = [UserPrefs getString:[guuid stringByAppendingPathComponent:@"lm_level_name"] withDefault:@"Name"];
	NSLog(@"name: %@", name);
	NSString*	description = [UserPrefs getString:[guuid stringByAppendingPathComponent:@"lm_level_desc"] withDefault:@"Description"];
	NSLog(@"description: %@", description);
	
	// change level properties
	NSMutableDictionary*	props = [Folders getMutableFolderProps:folder];
	[props setObject:name forKey: @"name"];
	[props setObject:description forKey: @"description"];
	[Folders setProps:props forFolder:folder];
	NSLog(@"level props saved");
	
	// clear related caches
	[Folders clearDomainCache:NULL];
	[GameManager clearCache];
	NSLog(@"domain/game-manager caches cleared");
	
	[self updateProgress:-1.0 withMessage:@"Renamed"];
	return FALSE;
}

@end
