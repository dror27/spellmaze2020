//
//  PrefFileActionDelegate.h
//  Board3
//
//  Created by Dror Kessler on 8/16/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefActionItem.h"
#import "PurchaseRecord.h"


@interface PrefFileActionDelegate : NSObject<PrefActionItemDelegate> {
	
	NSDictionary*	_props;
	NSString*		_billingItem;
}
@property (retain) NSDictionary* props;
@property (retain) NSString* billingItem;

-(BOOL)shouldDownload;
-(NSString*)downloadLabel;

@end
