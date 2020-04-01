//
//  PrefThreadedActionItem.h
//  Board3
//
//  Created by Dror Kessler on 8/5/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefActionItem.h"

@class PrefViewController;
@interface PrefThreadedActionItem : PrefActionItem {

	NSString*			_runningLabel;

	BOOL				running;
	PrefViewController*	_runningInController;
	
}
@property (retain) NSString* runningLabel;
@property (nonatomic,assign) PrefViewController* runningInController;

-(BOOL)runAction;
-(void)endAction;
-(void)updateLabel:(NSString*)value;
-(void)updateProgress:(float)progress withMessage:(NSString*)message;
-(void)updateMessage:(NSString*)message;
@end
