//
//  PrefUUIDAction.m
//  Board3
//
//  Created by Dror Kessler on 8/20/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefUUIDActionItem.h"
#import "PrefThreadedActionItem.h"
#import "Folders.h"
#import "JIMInterp.h"
#import "UUIDUtils.h"
#import "L.h"

@interface PrefUUIDActionItem (Privates)
-(void)saveAsAction;
@end


@implementation PrefUUIDActionItem
@synthesize uuid = _uuid;
@synthesize domain = _domain;
@synthesize actionScript = _actionScript;
@synthesize param = _param;
@synthesize startup;

-(void)dealloc
{
	[_uuid release];
	[_domain release];
	[_actionScript release];
	[_param release];
	
	[super dealloc];
}

-(BOOL)runAction
{
	// starting
	//[self updateProgress:-1.0 withMessage:self.actionScript];
	
#if SCRIPTING
	// do stuff here ...
	JIMInterp*		interp = [[[JIMInterp alloc] init] autorelease];
	NSString*		path = [[Folders findUUIDSubFolder:NULL forDomain:self.domain withUUID:self.uuid] stringByAppendingPathComponent:self.actionScript];
	[interp eval:[NSString stringWithContentsOfFile:path] withPath:path];
	id				result = [interp eval:[NSString stringWithFormat:@"action %@", [JIMInterp objectAsCommand:self]]];
	[self updateProgress:-1.0 withMessage:[NSString stringWithFormat:@"%@", result]];
#else
	[self updateProgress:-1.0 withMessage:[NSString stringWithFormat:@"%@", @"ActionClassMissing"]];	
#endif
	sleep(1);
	
	// done
	[self updateProgress:-1.0 withMessage:LOC(@"Completed")];
	[self performSelectorOnMainThread:@selector(reportDidFinish:) withObject:NULL waitUntilDone:FALSE];
	
	// does not linger ... (i.e. it ends here)
	return FALSE;
}

-(NSString*)createUUID
{
	return [UUIDUtils createUUID];
}

-(void)saveAsAction
{
	// make up a new UUID
	NSString*	newUUID = [UUIDUtils createUUID];
	
	// get current level folder
	NSString*	folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LEVELS withUUID:self.uuid];
	if ( !folder )
		return;
	
	// establish new folder
	NSString*	newFolder = [[folder stringByDeletingLastPathComponent] stringByAppendingPathComponent:newUUID];
	
	// copy the folder's content
	NSError*			error;
	NSFileManager*		fileManager = [NSFileManager defaultManager];
	if ( ![fileManager copyItemAtPath:folder toPath:newFolder error:&error] )
	{
		NSLog(@"ERROR - %@", error);
		return;
	}
	
	// copy level preferences ...
}


@end
