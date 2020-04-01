//
//  StoreManager.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "PurchaseRecord.h"


@class StoreManager;
@protocol StoreImplementation;

#define		STORE_ERROR_DOMAIN			@"StoreImplementation"
#define		STORE_ALREADY_PURCAHSED		101
#define		STORE_INVALID_ITEM			103

#define		STORE_PRICE_FREE			@"Free"

#define		STORE_ALLOW_PURCHASED_QUOTE	TRUE
#define		PREF_KEY_PURCHASE_RECORDS	@"_purchase-records"





@protocol StoreQuoteDelegate
-(void)store:(id<StoreImplementation>)store didQuote:(PurchaseRecord*)pr;
-(void)store:(id<StoreImplementation>)store quoteFailed:(PurchaseRecord*)pr withError:(NSError*)error;
@end


@protocol StorePurchaseDelegate
-(void)store:(id<StoreImplementation>)store didPurchase:(PurchaseRecord*)pr;
-(void)store:(id<StoreImplementation>)store purchaseFailed:(PurchaseRecord*)pr withError:(NSError*)error;
@end


@protocol StoreImplementation<NSObject>
-(BOOL)canMakePayments;
-(void)quote:(NSArray*)billingItems withDelegate:(id<StoreQuoteDelegate>)delegate;
-(void)purchase:(NSString*)billingItem withDelegate:(id<StorePurchaseDelegate>)delegate;
-(StoreManager*)storeManager;
@end



@interface StoreManager : NSObject<SKProductsRequestDelegate> {

	NSDictionary*				_stores;
}
@property (retain) NSDictionary* stores;

+(StoreManager*)singleton;

-(id<StoreImplementation>)storeForBillingItem:(NSString*)billingCode;
-(id<StoreImplementation>)storeByKey:(NSString*)storeKey;
-(NSString*)storeKey:(id<StoreImplementation>)store;


-(NSArray*)allPurchaseRecords;
-(PurchaseRecord*)findOrCreatePurchaseRecordForBillingItem:(NSString*)billingItem;
-(void)addOrUpdatePurchaseRecord:(PurchaseRecord*)pr;


@end
