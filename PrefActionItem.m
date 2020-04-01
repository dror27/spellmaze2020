//
//  PrefActionItem.m
//  Board3
//
//  Created by Dror Kessler on 8/4/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefActionItem.h"


@implementation PrefActionItem
@synthesize delegate = _delegate;
@synthesize disabled = _disabled;

-(UIView*)control
{
	return NULL;
}

-(BOOL)selectable
{
	return TRUE;
}

-(void)wasSelected:(UIViewController*)inController
{
	NSLog(@"PrefActionItem: wasSelected");
}

-(void)reportDidFinish:(NSError*)error
{
	if ( self.delegate && [self.delegate respondsToSelector:@selector(prefActionItem:didFinish:)] )
		[self.delegate prefActionItem:self didFinish:(error == NULL)];
}
@end
