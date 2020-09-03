//
//  WidgetBase.m
//  Board3
//
//  Created by Dror Kessler on 7/17/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "WidgetBase.h"


@implementation WidgetBase
@synthesize tickCounter = _tickCounter;
@synthesize tickTimer = _tickTimer;

-(void)startTickTimer:(int)counter
{
	[self stopTickTimer];
	
	self.tickCounter = counter;
	self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTickTimer) userInfo:nil repeats:YES]; 	
}

-(void)stopTickTimer
{
	if ( self.tickTimer && [self.tickTimer isValid] )
		[self.tickTimer invalidate];
	self.tickTimer = NULL;
}

-(void)onTickTimer
{
	self.tickCounter = self.tickCounter - 1;
	if ( self.tickCounter == 0 )
		[self onTickCounterZero];
}

-(void)onTickCounterZero
{
	
}

-(void)dealloc
{
	[self stopTickTimer];
	
	[_tickTimer release];
	
	[super dealloc];
}



@end
