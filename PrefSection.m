//
//  PrefSection.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefSection.h"
#import "PrefItemBase.h"


@implementation PrefSection
@synthesize title = _title;
@synthesize comment = _comment;
@synthesize items = _items;
@synthesize commentLabel = _commentLabel;
@synthesize viewController = _viewController;

-(void)dealloc
{
	[_title release];
	[_comment release];
	[_items release];
	[_commentLabel release];
	
	[super dealloc];
}

-(void)refresh
{
	for ( PrefItemBase* item in self.items )
		[item refresh];
	[_commentLabel setText:_comment];
}

-(void)appearedIn:(UIViewController*)viewController;
{
	self.viewController = viewController;
	
	for ( PrefItemBase* item in self.items )
		[item appeared];	
}

-(void)disappeared
{
	for ( PrefItemBase* item in self.items )
		[item disappeared];	
}

-(void)setComment:(NSString*)comment
{
	[_comment autorelease];
	_comment = [comment retain];
	
	[_commentLabel setText:_comment];
}

@end
