//
//  PerfAllPurchaseRecordsSection.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefPurchaseRecordsSection.h"
#import "PrefPurchaseRecordPage.h"
#import "StoreManager.h"
#import "PrefPage.h"
#import "PrefPageItem.h"
#import "PrefLabelItem.h"


@implementation PrefPurchaseRecordsSection
@synthesize stateMask;

-(NSArray*)items
{
	if ( ![super items] )
	{
		NSMutableArray*		items = [NSMutableArray array];
		
		for ( PurchaseRecord* pr in [[StoreManager singleton] allPurchaseRecords] )
		{
			PurchaseRecordState	state = [pr calculatedState];
			if ( stateMask && !((1 << state) & stateMask) )
				continue;
			
			PrefPage*			itemPage = [[[PrefPurchaseRecordPage alloc] initWithBillingItem:pr.billingItem] autorelease];
			PrefPageItem*		item = [[[PrefPageItem alloc] initWithLabel:[pr displayName] andKey:@"" andPage:itemPage] autorelease];
			item.viewControllerClassName = @"PrefPurchaseRecordViewController";
			item.viewControllerArgument = pr.billingItem;
			
			[items addObject:item];
		}
		
		if ( ![items count] )
		{
			PrefLabelItem*		item = [[[PrefLabelItem alloc] initWithLabel:@"No Records" andKey:NULL] autorelease];
			
			[items addObject:item];
		}
		
		[super setItems:items];
	}
	
	return [super items];
}

-(void)refresh
{
	[super setItems:nil];
	[super refresh];
}


@end
