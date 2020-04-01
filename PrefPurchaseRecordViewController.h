//
//  PrefPurchaseRecordViewController.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>


@interface PrefPurchaseRecordViewController : UIViewController {

	NSString*	_billingItem;
}
@property (retain) NSString* billingItem;

-(id)initWithArgument:(NSObject*)billingItem;
@end
