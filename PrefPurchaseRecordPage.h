//
//  PrefPurchaseRecordPage.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefPage.h"

@interface PrefPurchaseRecordPage : PrefPage {

	NSString*	_billingItem;
}
@property (retain) NSString* billingItem;

-(id)initWithBillingItem:(NSString*)billingItem;

@end
