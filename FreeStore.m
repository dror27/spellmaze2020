//
//  FreeStore.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FreeStore.h"
#import "UUIDUtils.h"

#define	FREE_STORE_NAME		NULL
#define	FREE_STORE_DESC		NULL

@interface FreeStore (Privates)
@end

@implementation FreeStore
@synthesize storeManager = _storeManager;

-(id)initWithStoreManager:(StoreManager*)storeManager
{
	if ( self = [super init] )
	{
		self.storeManager = storeManager;
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(BOOL)canMakePayments
{
	return TRUE;
}

-(void)quote:(NSArray*)billingItems withDelegate:(id<StoreQuoteDelegate>)delegate
{
	// loop on billing items
	for ( NSString* billingItem in billingItems )
	{
		// find or create the purchase record
		PurchaseRecord*		pr = [_storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];
		
		// fail if already purchased
		if ( !STORE_ALLOW_PURCHASED_QUOTE && pr.purchasedAt )
		{
			[delegate store:self quoteFailed:pr withError:[NSError errorWithDomain:STORE_ERROR_DOMAIN code:STORE_ALREADY_PURCAHSED userInfo:nil]];
			continue;
		}
		
		// fill billing information
		pr.billingName = FREE_STORE_NAME;
		pr.billingDesc = FREE_STORE_DESC;
		pr.billingPrice = STORE_PRICE_FREE;
		pr.quotedAt = [NSDate date];
		
		// save
		[_storeManager addOrUpdatePurchaseRecord:pr];
		
		// notify delegate
		[delegate store:self didQuote:pr];
	}
}

-(void)purchase:(NSString*)billingItem withDelegate:(id<StorePurchaseDelegate>)delegate
{
	// find or create the purchase record
	PurchaseRecord*		pr = [_storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];

	// if already purchased, this is a major error!
	if ( pr.purchasedAt )
	{
		NSLog(@"[FreeStore] ERROR - already purchased! %@", pr.billingItem);
		[delegate store:self purchaseFailed:pr withError:[NSError errorWithDomain:STORE_ERROR_DOMAIN code:STORE_ALREADY_PURCAHSED userInfo:nil]];
		return;
	}
	
	// fill purchase information
	pr.purchasedAt = [NSDate date];
	pr.purchaseReceipt = [@"SF:" stringByAppendingString:[UUIDUtils createUUID]];

	// save
	[_storeManager addOrUpdatePurchaseRecord:pr];
	
	// notify delegate
	[delegate store:self didPurchase:pr];	
}

@end
