//
//  PrefShowLastStatusOntologyActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefShowLastStatusOntologyActionLabel.h"
#import "Folders.h"
#import "L.h"


@implementation PrefShowLastStatusOntologyActionLabel

-(BOOL)sourceLabel
{
	return TRUE;
}

-(void)appeared
{
	[self refresh];
	
	[super appeared];
}

-(void)refresh
{
	NSString*	text = LOC(@"Never updated");
	NSDate*		date = NULL;
	
	// get folder, find out update date from words.txt file or use updated-on key
	NSString*			folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:_uuid];
	NSDictionary*		props = [Folders getMutableFolderProps:folder];
	NSNumber*			updatedOn = [props objectForKey:@"updated-on"];
	
	if ( updatedOn )
	{
		if ( [updatedOn integerValue] )
			date = [NSDate dateWithTimeIntervalSince1970:[updatedOn integerValue]];
			
	}
	else if ( folder )
	{
		NSString*		path = [folder stringByAppendingPathComponent:@"words.txt"];
		NSFileManager*	fileManager = [NSFileManager defaultManager];
		NSError*		error;
		NSDictionary*	dict = [fileManager attributesOfItemAtPath:path error:&error];
		
		if ( !dict )
			NSLog(@"ERROR - @%", error);
		else
			date = [dict objectForKey:NSFileModificationDate];
	}
	
	if ( date )
	{
		NSDateFormatter*	dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"dd/MM/yy HH:mm:ss"];
		
		NSString*			modDate = [dateFormatter stringFromDate:date];
		
		text = [NSString stringWithFormat:LOC(@"Last updated on %@"), modDate];				
	}
		
	[self setLabel:text];

	[super refresh];
}



@end
