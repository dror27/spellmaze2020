//
//  PrefPurchaseRecordPage.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefPurchaseRecordPage.h"
#import "StoreManager.h"


@implementation PrefPurchaseRecordPage
@synthesize billingItem = _billingItem;

-(id)initWithBillingItem:(NSString*)billingItem
{
	if ( self = [super init] )
	{
		self.billingItem = billingItem;
	}
	return self;
}

-(void)dealloc
{
	[_billingItem release];
	
	[super dealloc];
}



@end
