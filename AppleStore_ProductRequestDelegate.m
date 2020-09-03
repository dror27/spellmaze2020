//
//  AppleStore_ProductRequestDelegate.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/1/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "AppleStore_ProductRequestDelegate.h"
#import "AppleStore.h"

//#define	DUMP

@interface AppleStore_ProductRequestDelegate (Privates)
-(NSString*)buildBillingPrice:(NSDecimalNumber*)price withPriceLocale:(NSLocale*)priceLocale;
@end


@implementation AppleStore_ProductRequestDelegate
@synthesize store = _store;
@synthesize quoteDelegate = _quoteDelegate;
@synthesize billingCodeToBillingItemsDict = _billingCodeToBillingItemsDict;

-(id)init
{
	if ( self = [super init] )
	{
		self.billingCodeToBillingItemsDict = [NSMutableDictionary dictionary];
	}
	return self;
}

-(void)dealloc
{
	[_billingCodeToBillingItemsDict release];
	
	[super dealloc];
}

-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
#ifdef DUMP
	NSLog(@"[productsRequest:didReceiveResponse:] - request=%@", request);
	NSLog(@"[productsRequest:didReceiveResponse:] - response=%@", response);
	
	NSLog(@"[productsRequest:didReceiveResponse:] - products=%@", response.products);
	NSLog(@"[productsRequest:didReceiveResponse:] - invalidProductIdentifiers=%@", response.invalidProductIdentifiers);
#endif
	
	// transmit quotes to delegate
	for ( SKProduct* product in response.products )
	{
		NSString*		billingCode = product.productIdentifier;
		NSSet*			billingItems = [_billingCodeToBillingItemsDict objectForKey:billingCode];
		
		for ( NSString* billingItem in billingItems )
		{
			// find or create the purchase record
			PurchaseRecord*		pr = [_store.storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];
			
			// fail if already purchased
			if ( !STORE_ALLOW_PURCHASED_QUOTE && pr.purchasedAt )
			{
				[_quoteDelegate store:_store quoteFailed:pr withError:[NSError errorWithDomain:STORE_ERROR_DOMAIN code:STORE_ALREADY_PURCAHSED userInfo:nil]];
				continue;
			}
			
			// fill billing information
			pr.billingName = product.localizedTitle;
			pr.billingDesc = product.localizedDescription;
			pr.billingPrice = [self buildBillingPrice:product.price withPriceLocale:product.priceLocale];
			pr.quotedAt = [NSDate date];
			
			// save
			[_store.storeManager addOrUpdatePurchaseRecord:pr];
		
			// notify delegate
			[_quoteDelegate store:_store didQuote:pr];		
		}
	}
	
	// code to handle invalid product identifiers ...
	for ( NSString* billingCode in response.invalidProductIdentifiers )
	{
		NSSet*			billingItems = [_billingCodeToBillingItemsDict objectForKey:billingCode];

		for ( NSString* billingItem in billingItems )
		{
			// find or create the purchase record
			PurchaseRecord*		pr = [_store.storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];
		
			[_quoteDelegate store:_store quoteFailed:pr withError:[NSError errorWithDomain:STORE_ERROR_DOMAIN code:STORE_INVALID_ITEM userInfo:nil]];
		}
	}
	
    [request autorelease];
	[self autorelease];
}

-(NSString*)buildBillingPrice:(NSDecimalNumber*)price withPriceLocale:(NSLocale*)priceLocale
{
	NSNumberFormatter*		currencyStyle = [[[NSNumberFormatter alloc] init] autorelease];
	
	[currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
	[currencyStyle setLocale:priceLocale];
	
	return [currencyStyle stringFromNumber:price];
}

-(void)associateBillingItem:(NSString*)billingItem withBillingCode:(NSString*)billingCode
{
	if ( ![_billingCodeToBillingItemsDict objectForKey:billingCode] )
		[_billingCodeToBillingItemsDict setObject:[NSMutableSet set] forKey:billingCode];
	
	NSMutableSet*		set = [_billingCodeToBillingItemsDict objectForKey:billingCode];
	
	[set addObject:billingItem];
}
@end
