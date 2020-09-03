//
//  PrefActionItem.h
//  Board3
//
//  Created by Dror Kessler on 8/4/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefItemBase.h"

@protocol PrefActionItemDelegate;
@interface PrefActionItem : PrefItemBase {

	id<PrefActionItemDelegate>		_delegate;
	BOOL							_disabled;
	
}
@property (nonatomic,assign) id<PrefActionItemDelegate> delegate;
@property BOOL disabled;
-(void)reportDidFinish:(NSError*)error;
@end


@protocol PrefActionItemDelegate<NSObject>
-(void)prefActionItem:(PrefActionItem*)item didFinish:(BOOL)success;
@end
