//
//  PrefCheckForUpdatesActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 12/23/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefCheckForUpdatesActionItem.h"
#import "PurchaseRecord.h"
#import "StoreManager.h"
#import "PrefUrlDirectorySection.h"
#import "PrefCompoundSection.h"
#import "L.h"

//#define	DUMP

@interface PrefCheckForUpdatesActionItem (Privates)
-(NSArray*)checkForUpdates;
-(PrefSection*)needsUpdatingSection:(PurchaseRecord*)pr;
@end

extern NSMutableDictionary*	globalData;

@implementation PrefCheckForUpdatesActionItem
@synthesize itemsForUpdatePage = _itemsForUpdatePage;

-(void)dealloc
{
	[_itemsForUpdatePage release];
	
	[super dealloc];
}

-(void)appeared
{
	[self wasSelected:_viewController];
}

-(BOOL)runAction
{
	[self updateProgress:-1.0 withMessage:@"Checking ..."];
	
	NSArray*		itemsSections = [self checkForUpdates];
	NSMutableArray*	pageSections = (NSMutableArray*)_itemsForUpdatePage.sections;
	if ( pageSections.count > 1 )
		[pageSections removeObjectsInRange:NSMakeRange(1, pageSections.count - 1)];
	
	PrefCompoundSection* newSection = [[[PrefCompoundSection alloc] init] autorelease];
	newSection.sections = itemsSections;
	[pageSections addObject:newSection];
	
	// update items section
	if ( [_viewController respondsToSelector:@selector(refreshTableContents:)] )
		[_viewController performSelectorOnMainThread:@selector(refreshTableContents:) withObject:self waitUntilDone:TRUE];
	
	int			itemCount = [itemsSections count]; 
	NSString*	message;
	if ( itemCount )
		message = [NSString stringWithFormat:LOC(@"Found %d Updates"), itemCount];
	else
		message = LOC(@"No Updates Found");
	[self performSelectorOnMainThread:@selector(updateMessageOnMainThread:) withObject:message waitUntilDone:TRUE];
	
	// does not linger ... (i.e. it ends here)
	//[self performSelectorOnMainThread:@selector(reportDidFinish:) withObject:NULL waitUntilDone:FALSE];
	return FALSE;
}

-(void)updateMessageOnMainThread:(NSString*)message
{
	[self performSelector:@selector(updateMessage:) withObject:message afterDelay:0.0];
}

-(NSArray*)checkForUpdates
{
	NSMutableArray*		sections = [NSMutableArray array];
	NSArray*			records = [[StoreManager singleton] allPurchaseRecords];
	int					recordIndex = 0;
	
	for ( PurchaseRecord* pr in records )
	{
		
		[self updateProgress:((float)recordIndex++ / [records count]) withMessage:@"Checking ..."];
		[NSThread sleepForTimeInterval:0.05];

		if ( [pr checkForUpdates] )
			[[StoreManager singleton] addOrUpdatePurchaseRecord:pr];
		PurchaseRecordState		state = [pr calculatedState];
		
		switch ( state )
		{
			case PurchaseRecordStateMissing :
			case PurchaseRecordStateOutdated :
			{
				
#ifdef DUMP
				NSLog(@"[checkForUpdates] %@ %@ %@ %d", pr, [pr billingName], [pr directoryEntry], state);
#endif
				
				PrefSection*	section = [self needsUpdatingSection:pr];
				if ( section )
					[sections addObject:section];
				break;
			}
		}
	}
	
	[self updateProgress:-2.0 withMessage:@"Wrapping Up ..."];
	
	return sections;
}

-(PrefSection*)needsUpdatingSection:(PurchaseRecord*)pr
{
	// build section
	PrefUrlDirectorySection*	moreSection1 = [[[PrefUrlDirectorySection alloc] initWithURL:[pr directoryUrl]] autorelease];
	moreSection1.limitToItemUUID = [pr billingItem];
	moreSection1.delegate = [globalData objectForKey:@"PrefMainPageBuilder_singleton"];
	
	return moreSection1;
}


@end
