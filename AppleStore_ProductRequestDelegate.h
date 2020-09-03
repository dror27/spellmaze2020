//
//  AppleStore_ProductRequestDelegate.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/1/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "StoreManager.h"

@class AppleStore;
@interface AppleStore_ProductRequestDelegate : NSObject<SKProductsRequestDelegate>
{
	AppleStore*					_store;
	id<StoreQuoteDelegate>		_quoteDelegate;
	NSMutableDictionary*		_billingCodeToBillingItemsDict;
}
@property (nonatomic,assign) AppleStore* store;
@property (nonatomic,assign) id<StoreQuoteDelegate> quoteDelegate;
@property (retain) NSMutableDictionary*	billingCodeToBillingItemsDict;

-(void)associateBillingItem:(NSString*)billingItem withBillingCode:(NSString*)billingCode;

@end
