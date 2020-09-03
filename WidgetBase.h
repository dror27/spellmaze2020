//
//  WidgetBase.h
//  Board3
//
//  Created by Dror Kessler on 7/17/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WidgetBase : NSObject {

	NSTimer*				_tickTimer;
	int						_tickCounter;
}
@property int tickCounter;
@property (retain) NSTimer* tickTimer;

-(void)startTickTimer:(int)counter;
-(void)stopTickTimer;
-(void)onTickTimer;
-(void)onTickCounterZero;

@end
