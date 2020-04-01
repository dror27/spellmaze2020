//
//  PrefThreadedActionItem.m
//  Board3
//
//  Created by Dror Kessler on 8/5/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefThreadedActionItem.h"
#import "PrefViewController.h"
#import "DisplayCell.h"
#import "SystemUtils.h"

//#define	DUMP

@implementation PrefThreadedActionItem
@synthesize runningLabel = _runningLabel;
@synthesize runningInController = _runningInController;

-(void)dealloc
{
	[_runningLabel release];
	
	[super dealloc];
}

-(void)wasSelected:(UIViewController*)inController
{
	if ( _disabled )
		return;
	
	if ( !running )
	{
		self.runningInController = (PrefViewController*)inController;
		running = TRUE;
		[self updateLabel:self.runningLabel];
		
		// start a thread to perform action
		[SystemUtils threadWithTarget:self selector:@selector(runActionThread:) object:inController];
		//[NSThread detachNewThreadSelector:@selector(runActionThread:) toTarget:self withObject:inController];
	}
	else
	{
		// for now, ignore selections when running. later implementing stop
	}
}

-(void)idleTimerDisabled:(NSNumber*)value
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:[value boolValue]];	
}

-(void)runActionThread:(UIViewController*)inController
{
	NSAutoreleasePool*		pool = [[NSAutoreleasePool alloc] init];

	[self performSelectorOnMainThread:@selector(idleTimerDisabled:) withObject:[NSNumber numberWithBool:TRUE] waitUntilDone:TRUE];
	
	BOOL					continuesAsync = [self runAction];
	
	[self performSelectorOnMainThread:@selector(idleTimerDisabled:) withObject:[NSNumber numberWithBool:FALSE] waitUntilDone:TRUE];
	
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setIdleTimerDisabled:FALSE];
    });
	

	
	if ( !continuesAsync )
		[self endAction];
	
	[pool release];
	
#ifdef DUMP
	NSLog(@"Thread exiting ...");
#endif
}

-(BOOL)runAction
{
	return FALSE;
}

-(void)endAction
{
	sleep(1);	// let user appriciate what just happend

	// mark done
	//[self performSelectorOnMainThread:@selector(updateLabel:) withObject:self.label waitUntilDone:FALSE];
	running = FALSE;

	[_runningInController performSelectorOnMainThread:@selector(viewWillAppear:) withObject:nil waitUntilDone:FALSE];
}

-(void)updateLabel:(NSString*)value
{
	if ( !value || ![value length] )
		return;
	
	UITableViewCell		*cell = [_runningInController.itemCells objectForKey:self];
	if ( !cell )
		return;
	
	((DisplayCell*)cell).nameLabel.text = value;
}

-(void)updateMessage:(NSString*)message
{
	[self updateProgress:-1.0 withMessage:message];
}	

-(void)updateProgress:(float)progress withMessage:(NSString*)message
{
#ifdef DUMP
	NSLog(@"updateProgress: %f, %@", progress, message);
#endif
	
	// for now ...
	NSString*	text;
	if ( progress >= 0.0 )
		text = [NSString stringWithFormat:@"%@ (%02.0f%%)", message, progress * 100.0];
	else
		text = message;
	
	if ( [[NSThread currentThread] isMainThread] )
		[self updateLabel:text];
	else
		[self performSelectorOnMainThread:@selector(updateLabel:) withObject:text waitUntilDone:(progress < -1.0)];
}

@end
