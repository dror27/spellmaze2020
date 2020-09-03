//
//  AppleStore.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/31/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "StoreManager.h"


@interface AppleStore : NSObject<StoreImplementation,SKPaymentTransactionObserver> {

	StoreManager*			_storeManager;
	NSMutableDictionary*	_billingCodePurchaseObjects;
}
@property (nonatomic,assign) StoreManager* storeManager;
@property (retain) NSMutableDictionary*	billingCodePurchaseObjects;

-(id)initWithStoreManager:(StoreManager*)storeManager;

@end
