//
//  AppleStore.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppleStore.h"
#import "AppleStore_ProductRequestDelegate.h"
#import "NSData_TextRepresentation.h"

//#define	DUMP

@interface AppleStore (Privates)
@end


@implementation AppleStore
@synthesize storeManager = _storeManager;
@synthesize billingCodePurchaseObjects = _billingCodePurchaseObjects;


-(id)initWithStoreManager:(StoreManager*)storeManager
{
	if ( self = [super init] )
	{
		self.storeManager = storeManager;
		self.billingCodePurchaseObjects = [NSMutableDictionary dictionary];
		
		// add self as the transaction observer
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}
	return self;
}

-(void)dealloc
{
	[_billingCodePurchaseObjects release];
	
	[super dealloc];
}

-(BOOL)canMakePayments
{
	return [SKPaymentQueue canMakePayments];
}

-(void)quote:(NSArray*)billingItems withDelegate:(id<StoreQuoteDelegate>)quoteDelegate
{
#ifdef DUMP
	NSLog(@"[quote:] - billingItems=%@", billingItems);
#endif
	
	NSMutableSet*						productIdentifiers = [NSMutableSet set];
	AppleStore_ProductRequestDelegate*	delegate = [[AppleStore_ProductRequestDelegate alloc] init];
	for ( NSString* billingItem in billingItems )
	{
		PurchaseRecord*		pr = [_storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];
		NSString*			code = [pr naturalBillingCode];
		
		[productIdentifiers addObject:code];
		[delegate associateBillingItem:billingItem withBillingCode:code];
	}
#ifdef DUMP
	NSLog(@"[quote:] - productIdentifiers=%@", productIdentifiers);
#endif
	
	SKProductsRequest*					request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	
	delegate.store = self;
	delegate.quoteDelegate = quoteDelegate;
	request.delegate = delegate;
	
	[request start];
}

-(void)purchase:(NSString*)billingItem withDelegate:(id<StorePurchaseDelegate>)delegate
{
#if 0

	PurchaseRecord*		pr = [_storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];
	NSString*			code = [pr naturalBillingCode];
	
	SKPayment*			payment = [SKPayment paymentWithProductIdentifier:code];

	[_billingCodePurchaseObjects setObject:[NSArray arrayWithObjects:billingItem, delegate, NULL] forKey:code];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
#endif
}

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
-(void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{	
	for ( SKPaymentTransaction* transaction in transactions )
	{
#ifdef DUMP
		NSLog(@"paymentQueue:updatedTransactions: %@ %d", transaction, transaction.transactionState);
#endif

		NSString*					billingCode = transaction.payment.productIdentifier;
		NSArray*					objects = [_billingCodePurchaseObjects objectForKey:billingCode];
		NSString*					billingItem = [objects objectAtIndex:0];
		id<StorePurchaseDelegate>	delegate = [objects objectAtIndex:1];
		PurchaseRecord*				pr = [_storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];

		switch ( transaction.transactionState )
		{
			// Transaction is being added to the server queue.
			case SKPaymentTransactionStatePurchasing :
			{
#ifdef DUMP
				NSLog(@"SKPaymentTransactionStatePurchasing");
#endif
				
				// not much to do ...
				
				break;
			}
				
			// Transaction is in queue, user has been charged.  Client should complete the transaction.
			case SKPaymentTransactionStatePurchased :
			{
#ifdef DUMP
				NSLog(@"SKPaymentTransactionStatePurchased");
#endif
				
				// positive path
#if 0
				pr.purchasedAt = transaction.transactionDate;
				pr.purchaseReceipt = [@"AS:" stringByAppendingString:[transaction.transactionReceipt textRepresentation]];
#endif
				// save
				[_storeManager addOrUpdatePurchaseRecord:pr];
				
				// notify delegate
				[delegate store:self didPurchase:pr];	
				
				
				[queue finishTransaction:transaction];
				[_billingCodePurchaseObjects removeObjectForKey:billingItem];
				break;
			}
			
			// Transaction was cancelled or failed before being added to the server queue.	
			case SKPaymentTransactionStateFailed :
			{
#ifdef DUMP
				NSLog(@"SKPaymentTransactionStateFailed");
#endif
				
				// negative path
				[delegate store:self purchaseFailed:pr withError:transaction.error];
				
				[queue finishTransaction:transaction];
				[_billingCodePurchaseObjects removeObjectForKey:billingItem];
				break;
			}
				
			 // Transaction was restored from user's purchase history.  Client should complete the transaction.
			case SKPaymentTransactionStateRestored :      
			{
#ifdef DUMP
				NSLog(@"SKPaymentTransactionStateRestored");
#endif
				
				// recovery path
#if 0
				pr.purchasedAt = transaction.originalTransaction.transactionDate;
				pr.purchaseReceipt = [@"AS:" stringByAppendingString:[transaction.originalTransaction.transactionReceipt textRepresentation]];
#endif
				// save
				[_storeManager addOrUpdatePurchaseRecord:pr];
				
				break;
			}
		}
	}
}

// Sent when transactions are removed from the queue (via finishTransaction:).
-(void)paymentQueue:(SKPaymentQueue*)queue removedTransactions:(NSArray*)transactions
{
#ifdef DUMP
	NSLog(@"paymentQueue:removedTransactions:");	
#endif
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
-(void)paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error
{
#ifdef DUMP
	NSLog(@"paymentQueue:restoreCompletedTransactionsFailedWithError:");
#endif
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue
{
#ifdef DUMP
	NSLog(@"paymentQueueRestoreCompletedTransactionsFinished:");	
#endif
}

@end

#if 0
// find or create the purchase record
PurchaseRecord*		pr = [_storeManager findOrCreatePurchaseRecordForBillingItem:billingItem];

// if already purchased, this is a major error!
if ( pr.purchasedAt )
{
#ifdef DUMP
	NSLog(@"[FreeStore] ERROR - already purchased! %@", pr.billingItem);
#endif
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
#endif
