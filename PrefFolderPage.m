//
//  PrefFolderPage.m
//  Board3
//
//  Created by Dror Kessler on 8/10/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefFolderPage.h"
#import "PrefSection.h"
#import "PrefPageItem.h"
#import "PrefFilePage.h"
#import "Folders.h"

@implementation PrefFolderPage
@synthesize path = _path;

-(id)initWithFolder:(NSString*)path
{
	if ( self = [super init] )
	{
		self.path = path;
	}
	return self;
}

-(void)dealloc
{
	[_path release];
	
	[super dealloc];
}

-(NSString*)title
{
	NSString*	title = [super title];
	
	if ( !title )
	{
		title = [self.path lastPathComponent];
		
		[super setTitle:title];
	}
	
	return title;
}

-(NSArray*)sections
{
	NSArray*	sections = [super sections];
	
	if ( !sections )
	{
		// two sections are created - for sub-folders and contained files.
		PrefSection*		folders = [[[PrefSection alloc] init] autorelease];
		PrefSection*		files = [[[PrefSection alloc] init] autorelease];
		NSMutableArray*		foldersItems = [[[NSMutableArray alloc] init] autorelease];
		NSMutableArray*		filesItems = [[[NSMutableArray alloc] init] autorelease];
		
		// loop over contents of the folder
		NSFileManager*		fileManager = [NSFileManager defaultManager];
		NSError*			error;
		for ( NSString* content in [fileManager contentsOfDirectoryAtPath:self.path error:&error] )
		{
			if ( [content hasPrefix:@"__"] || [content hasPrefix:@"."] )
				continue;
			
			NSString*		path = [self.path stringByAppendingPathComponent:content];
			NSDictionary*	dictionary = [fileManager attributesOfItemAtPath:path error:&error];
			BOOL			isFolder = [[dictionary fileType] isEqualToString:NSFileTypeDirectory];
	
			if ( isFolder )
			{
				PrefPage*		itemPage = [[[PrefFolderPage alloc] initWithFolder:path] autorelease];
				NSString*		name = [path lastPathComponent];
				
				// get name from props.plist?
				NSDictionary*	props = [Folders getMutableFolderProps:path];
				if ( [props objectForKey:@"name"] )
					name = [props objectForKey:@"name"];
				
				PrefPageItem*	item = [[[PrefPageItem alloc] initWithLabel:name andKey:@"" andPage:itemPage] autorelease];
				
				[foldersItems addObject:item];
			}
			else
			{
				PrefPage*		itemPage = [[[PrefFilePage alloc] initWithFile:path] autorelease];
				PrefPageItem*	item = [[[PrefPageItem alloc] initWithLabel:[path lastPathComponent] andKey:@"" andPage:itemPage] autorelease];
				item.viewControllerClassName = @"PrefFileViewController";
				item.viewControllerArgument = path;
				
				[filesItems addObject:item];				
			}
		}
		
		// sort item lists
		NSArray*		sortDescriptors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"label" ascending:TRUE]];
		[foldersItems sortUsingDescriptors:sortDescriptors];
		[filesItems sortUsingDescriptors:sortDescriptors];

		// setup
		folders.title = [NSString stringWithFormat:@"Folders (%d)", [foldersItems count]];
		folders.items = foldersItems;
		files.title = [NSString stringWithFormat:@"Files (%d)", [filesItems count]];
		files.items = filesItems;
		NSMutableArray*		mutableSections = [[[NSMutableArray alloc] init] autorelease];
		if ( [foldersItems count] )
			[mutableSections addObject:folders];
		if ( [filesItems count] )
			[mutableSections addObject:files];
		if ( [mutableSections count] == 0 )
		{
			folders.comment = @"Folder is empty";
			[mutableSections addObject:folders];
		}
		
		sections = mutableSections;
		[super setSections:sections];
	}
	return sections;
}


@end
