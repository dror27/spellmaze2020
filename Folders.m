//
//  Folders.m
//  Board3
//
//  Created by Dror Kessler on 8/5/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "Folders.h"
#import "GameManager.h"

//#define	DUMP

static NSMutableDictionary*				listDomainCache;

static NSArray*							defaultRoleSearchOrderArray;

static NSMutableDictionary*				domainCurrentKey;

@implementation Folders

+(NSArray*)defaultRoleSearchOrder
{
	@synchronized ([Folders class])
	{
		if ( !defaultRoleSearchOrderArray )
			defaultRoleSearchOrderArray = [[NSArray arrayWithObjects:
										   [NSNumber numberWithInt:FolderRoleCurrentGame],
										   [NSNumber numberWithInt:FolderRoleDownload],
										   [NSNumber numberWithInt:FolderRoleBuiltin],
										   NULL] retain];
	}

	return defaultRoleSearchOrderArray;
}

+(NSString*)roleFolder:(FolderRoleType)role forDomain:(NSString*)domain
{
	NSString*	folder = NULL;
	
	switch ( role )
	{
		case FolderRoleBuiltin :
			folder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Builtin"];
			folder = [folder stringByAppendingPathComponent:[GameManager programUuid]];
			break;
			
		case FolderRoleDownload :
		{
			NSArray			*paths;
			
			paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			if ( [paths count] > 0 )
				folder = [[paths objectAtIndex:0] stringByAppendingPathComponent:[GameManager programUuid]];
			break;
		}
			
		case FolderRoleCurrentGame :
		{
			// this is not applicable for game searches of course
			if ( [domain isEqualToString:DF_GAMES] )
				return NULL;
			
			NSString*		gameUUID = [UserPrefs getString:PK_LEVEL_SET withDefault:GM_DEFAULT_GAME];
			folder = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES withUUID:gameUUID];
			break;
		}
	}
	
	if ( domain && folder )
		folder = [folder stringByAppendingPathComponent:domain];
	
#ifdef DUMP	
	NSLog(@"roleFolder: %d - %@", role, folder);
#endif	
	return folder;
}


+(NSString*)temporaryFolder
{
	return NSTemporaryDirectory();
}

+(NSArray*)listUUIDSubFolders:(NSArray*)roleSearchOrder forDomain:(NSString*)domain;
{
	NSMutableArray*		paths = [[[NSMutableArray alloc] init] autorelease];
	NSFileManager*		fileManager = [NSFileManager defaultManager];
	NSMutableSet*		found = [[[NSMutableSet alloc] init] autorelease];

	if ( !roleSearchOrder )
		roleSearchOrder = [Folders defaultRoleSearchOrder];
	
	for ( id role in roleSearchOrder )
	{
		NSString*		folder = NULL;
		if ( [role isKindOfClass:[NSNumber class]] )
			folder = [Folders roleFolder:[((NSNumber*)role) intValue] forDomain:domain];
		if ( [role isKindOfClass:[NSString class]] )
		{
			NSArray*	toks = [((NSString*)role) componentsSeparatedByString:@":"];
			if ( [toks count] >= 2 ) 
			{
				NSString*	tokDomain = [toks objectAtIndex:0];
				NSString*	tokUUID = [toks objectAtIndex:1];
				
				folder = [[Folders findUUIDSubFolder:NULL forDomain:tokDomain withUUID:tokUUID] stringByAppendingPathComponent:domain];
			}
		}
		if ( !folder )
			continue;
		NSError*		error;
		NSArray*		contents = [fileManager contentsOfDirectoryAtPath:folder error:&error];
		if ( !contents )
		{
#ifdef DUMP
			NSLog(@"listSubFolders: ERROR - %@", error);
#endif
		}
		else
		{
			for ( NSString* uuid in contents )
			{
				if ( [uuid length] == 36 && ![found containsObject:uuid] )
				{
					[found addObject:uuid];
					
					[paths addObject:[folder stringByAppendingPathComponent:uuid]];
				}
			}
		}
	}

#ifdef	DUMP
	NSLog(@"listSubFolders: domain=%@", domain);
	for ( NSString* path in paths )
		NSLog(@"  %@", path);
#endif
	
	return paths;
}

+(NSString*)findUUIDSubFolder:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid
{
	NSArray*	paths = [Folders listUUIDSubFolders:roleSearchOrder forDomain:domain];
	NSString*	folder = NULL;
	
	for ( NSString* path in paths )
		if ( [uuid isEqualToString:[path lastPathComponent]] )
		{
			folder = path;
			break;
		}
	
	return folder;
}

+(NSString*)findMutableUUIDSubFolder:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid
{
	NSString*	folder = [Folders findUUIDSubFolder:roleSearchOrder forDomain:domain withUUID:uuid];
	
	// in built-in?
	if ( [folder hasPrefix:[Folders roleFolder:FolderRoleBuiltin forDomain:domain]] )
	{
		NSError*		error;
		
		folder = [[Folders roleFolder:FolderRoleDownload forDomain:DF_DYNAMIC] stringByAppendingPathComponent:uuid];
		[[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:TRUE attributes:NULL error:&error];
	}
	
	return folder;
}

+(NSString*)makeUUIDMutable:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid
{
	NSString*	folder = [Folders findUUIDSubFolder:roleSearchOrder forDomain:domain withUUID:uuid];
	
	// in built-in?
	if ( [folder hasPrefix:[Folders roleFolder:FolderRoleBuiltin forDomain:domain]] )
	{
		NSError*		error = NULL;
		NSString*		newFolder = [Folders roleFolder:FolderRoleDownload forDomain:domain];
#ifdef DUMP
		NSLog(@"makeUUIDMutable: \n src: %@\n dst: %@", folder, newFolder);
#endif
		
		// make destination folder
		[[NSFileManager defaultManager] createDirectoryAtPath:newFolder withIntermediateDirectories:TRUE attributes:nil error:&error];
		if ( error )
			NSLog(@"ERROR: %@", error);
				
		newFolder = [newFolder stringByAppendingPathComponent:uuid];

		// copy folder
		[[NSFileManager defaultManager] copyItemAtPath:folder toPath:newFolder error:&error];
		if ( error )
			NSLog(@"ERROR: %@", error);
		
		folder = newFolder;
	}
	
	return folder;
}

+(NSMutableDictionary*)getMutableFolderProps:(NSString*)folder
{
	return [Folders getMutableFolderProps:folder withPropsFilename:nil returnDefaultIfNotPresent:TRUE];
}

+(NSMutableDictionary*)getMutableFolderProps:(NSString*)folder withPropsFilename:(NSString*)filename returnDefaultIfNotPresent:(BOOL)returnDefaultIfNotPresent;
{
#ifdef DUMP
	NSLog(@"getMutableFolderProps: folder=%@", folder);
#endif	
	NSString*				path = [folder stringByAppendingPathComponent:filename ? filename : @"props.plist"];
#ifdef DUMP
	NSLog(@"[Folders] getMutableFolderProps: %@", path);
#endif	
	NSData*					data = [NSData dataWithContentsOfFile:path];
	NSString*				error = nil;
	NSPropertyListFormat	format;
	NSMutableDictionary*	props = [NSPropertyListSerialization propertyListFromData:data 
																mutabilityOption:NSPropertyListMutableContainersAndLeaves 
																format:&format
																errorDescription:&error];
	if ( !props || error )
	{
#ifdef DUMP
		NSLog(@"getMutableFolderProps: ERROR\n Folder: %@\n Error: %@\n", folder, error);
#endif	
		if ( !returnDefaultIfNotPresent )
			return nil;
		props = [[[NSMutableDictionary alloc] init] autorelease];
	}
	
	[props setObject:[folder lastPathComponent] forKey:@"uuid"];
	
	
	return props;
}

+(void)setProps:(NSDictionary*)props forFolder:(NSString*)folder
{
	NSString*				errorString = nil;
	
	// delete internals
	NSMutableDictionary*	dict = [NSMutableDictionary dictionaryWithDictionary:props];
	for ( NSString* key in [dict allKeys] )
		if ( [key hasPrefix:@"__"] )
			[dict removeObjectForKey:key];
	
	NSData*					data = [NSPropertyListSerialization dataFromPropertyList:dict 
												format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
	if ( !data || errorString )
	{
		NSLog(@"ERROR - %@", errorString);
		return;
	}
	
	NSString*				path = [folder stringByAppendingPathComponent:@"props.plist"];
	NSError*				error;
	if ( ![data writeToFile:path options:NSAtomicWrite error:&error] )
		NSLog(@"ERROR - %@", error);
}

+(NSArray*)listDomain:(NSString*)domain withRoleSearchOrder:(NSArray*)roleSearchOrder
{
	@synchronized ([Folders class]) 
	{
		if ( !listDomainCache )
			listDomainCache = [[NSMutableDictionary dictionary] retain];
		
		NSMutableString*		key = [NSMutableString stringWithString:domain];
		if ( roleSearchOrder )
			for ( id num in roleSearchOrder )
				[key appendFormat:@",%@", num];

		if ( ![listDomainCache objectForKey:key] )
		{
			NSMutableArray*		objects = [[[NSMutableArray alloc] init] autorelease];
			NSArray*			paths = [Folders listUUIDSubFolders:roleSearchOrder forDomain:domain];
			
			for ( NSString* path in paths )
			{
				NSString*				uuid = [path lastPathComponent];
				NSMutableDictionary*	props = [Folders getMutableFolderProps:(NSString*)path];
				if ( !props )
					props = [[[NSMutableDictionary alloc] init] autorelease];
				
				[props setObject:uuid forKey:@"uuid"];
				[props setObject:path forKey:@"_path"];
				
				[objects addObject:props];
			}
			
			[listDomainCache setObject:objects forKey:key];
		}
		
		return [listDomainCache objectForKey:key];
	}
	
	// never here
	return nil;
}

static int listDomainSorted_sortFunction(id a, id b, void* context)
{
	NSDictionary*		aProps = a;
	NSDictionary*		bProps = b;
	
	NSString*			aName = [aProps objectForKey:@"name"];
	NSString*			bName = [bProps objectForKey:@"name"];
	
	BOOL				aValid = [aName isKindOfClass:[NSString class]];
	BOOL				bValid = [bName isKindOfClass:[NSString class]];
	
	if ( !aValid && !bValid )
		return NSOrderedSame;
	else if ( aValid && !bValid )
		return NSOrderedAscending;
	else if ( !aValid && bValid )
		return NSOrderedDescending;
	else
		return [aName compare:bName];
	
}

+(NSArray*)listDomainSorted:(NSString*)domain withRoleSearchOrder:(NSArray*)roleSearchOrder
{
	return [[Folders listDomain:domain withRoleSearchOrder:roleSearchOrder] sortedArrayUsingFunction:listDomainSorted_sortFunction context:NULL];
}


+(void)clearDomainCache:(NSString*)domain
{
	@synchronized ([Folders class])
	{
		if ( listDomainCache )
		{
			if ( domain )
				[listDomainCache removeObjectForKey:domain];
			else
				[listDomainCache removeAllObjects];
		}
	}
}

+(void)clearRoleFolder:(FolderRoleType)role forDomain:(NSString*)domain
{
	// can not clear built-in
	if ( role == FolderRoleBuiltin )
		return;
	
	NSString*		path = [Folders roleFolder:role forDomain:domain];
	if ( !path )
		return;
	NSFileManager*	fileManager = [NSFileManager defaultManager];
	NSError*		error;
	
	if ( ![fileManager removeItemAtPath:path error:&error] )
	{
#ifdef	DUMP
		NSLog(@"clearRoleFolder: ERROR - %@", error);
#endif
	}
}

+(void)copyFolder:(NSString*)srcFolder toFolder:(NSString*)dstFolder
{
	NSFileManager*	fileManager = [NSFileManager defaultManager];
	
	// make sure dst folder exists
	NSError*		error;
	[fileManager createDirectoryAtPath:dstFolder withIntermediateDirectories:TRUE attributes:nil error:&error];
	
	// loop over files in source folder, copy to destination
	NSArray*		contents = [fileManager contentsOfDirectoryAtPath:srcFolder error:&error];
	if ( contents )
	{
		for ( NSString* filename in contents )
			[fileManager copyItemAtPath:[srcFolder stringByAppendingPathComponent:filename] 
								 toPath:[dstFolder stringByAppendingPathComponent:filename] error:&error];
	}
	else
		NSLog(@"ERROR - %@", error);
}

+(void)removeFolder:(NSString*)folder
{
	NSFileManager*	fileManager = [NSFileManager defaultManager];	
	NSError*		error;
	
	if ( ![fileManager removeItemAtPath:folder error:&error] )
		NSLog(@"ERROR - %@", error);	
}

+(NSMutableDictionary*)findUUIDProps:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid
{
	NSString*		folder = [Folders findUUIDSubFolder:roleSearchOrder forDomain:domain withUUID:uuid];
	
	if ( folder )
	{
		NSMutableDictionary*	props = [Folders getMutableFolderProps:folder];
		
		[props setObject:folder forKey:@"__baseFolder"];
		
		return props;
	}
	else
	{
		NSMutableDictionary*	props = [[[NSMutableDictionary alloc] init] autorelease];
		
		[props setObject:uuid forKey:@"uuid"];
		
		return props;
	}
}

+(void)setProps:(NSDictionary*)props forUUID:(NSString*)uuid forDomain:(NSString*)domain withRoleSearchOrder:(NSArray*)roleSearchOrder
{
	NSString*		folder = [Folders findUUIDSubFolder:roleSearchOrder forDomain:domain withUUID:uuid];
	
	if ( folder )
		[Folders setProps:props forFolder:folder];
}

+(void)reportUUIDUpdated:(NSString*)uuid withDomain:(NSString*)domain
{
	@synchronized ([Folders class]) 
	{
		// init
		if ( !domainCurrentKey )
		{
			domainCurrentKey = [[NSMutableDictionary dictionary] retain];
			
			[domainCurrentKey setObject:PK_LANG_DEFAULT forKey:DF_LANGUAGES];
			[domainCurrentKey setObject:PK_LEVEL_SET forKey:DF_GAMES];
			[domainCurrentKey setObject:PK_BRAND forKey:DF_BRANDS];
			[domainCurrentKey setObject:PK_CATALOG forKey:DF_CATALOGS];
		}
		
		// has key
		NSString*		key = [domainCurrentKey objectForKey:domain];
		if ( key )
		{
			NSString*	value = [UserPrefs getString:key withDefault:nil];
			if ( [value isEqualToString:uuid] )
			{
				// the current item has just be updated, fire an update
				[UserPrefs fireDelegatesForKey:key];
			}
		}
		
	}
}

@end
