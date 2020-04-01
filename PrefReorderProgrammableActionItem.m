//
//  PrefReorderProgrammableActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefReorderProgrammableActionItem.h"
#import "Folders.h"
#import "GameManager.h"


@implementation PrefReorderProgrammableActionItem

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
	
	// update game
	NSString*				gfolder = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES withUUID:guuid];
	NSLog(@"gfolder: %@", gfolder);
	NSMutableDictionary*	gprops = [Folders getMutableFolderProps: gfolder];
	NSMutableArray*			levels = [gprops objectForKey:@"levels"];
	
	if ( [levels indexOfObject:uuid] >= 0 )
	{
		if ( [_param isEqualToString:@"first"] )
		{
			NSLog(@"moving to first");
			[levels removeObject:uuid];
			[levels insertObject:uuid atIndex:0];
		}
		else if ( [_param isEqualToString:@"up"] )
		{
			NSLog(@"moving up");
			int			index = [levels indexOfObject:uuid];
			if ( index > 0 )
			{
				[levels removeObject:uuid];	
				[levels insertObject:uuid atIndex:index - 1];
			}
		}
		else if ( [_param isEqualToString:@"down"] )
		{
			NSLog(@"moving down");
			int			index = [levels indexOfObject:uuid];
			int			lastIndex = [levels count] - 1;
			if ( index >= 0 && index < lastIndex )
			{
				[levels removeObject:uuid];	
				[levels insertObject:uuid atIndex:index + 1];
			}
		}
		else if ( [_param isEqualToString:@"last"] )
		{
			NSLog(@"moving to last");
			[levels removeObject:uuid];
			[levels addObject:uuid];
		}
	}
	
	[Folders setProps:gprops forFolder:gfolder];
	NSLog(@"level reordered");
	
	// clear related caches
	[Folders clearDomainCache:NULL];
	[GameManager clearCache];
	NSLog(@"domain/game-manager caches cleared");
	
	[self updateProgress:-1.0 withMessage:@"Reordered"];
	return FALSE;
}

@end
