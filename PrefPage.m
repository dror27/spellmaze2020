//
//  PrefPage.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefPage.h"
#import "PrefSection.h"

@implementation PrefPage
@synthesize title = _title;
@synthesize sections = _sections;
@synthesize pageViewController = _pageViewController;

-(void)dealloc
{
	[_title release];
	[_sections release];
	
	[super dealloc];
}

-(void)refresh
{
	if ( _title )
		[_pageViewController setTitle:_title];
	for ( PrefSection* section in self.sections )
		[section refresh];
}

-(void)appeared
{
	for ( PrefSection* section in self.sections )
		[section appearedIn:_pageViewController];	
}

-(void)disappeared
{
	for ( PrefSection* section in self.sections )
		[section disappeared];	
}

-(void)setTitle:(NSString*)title
{
	[_title autorelease];
	_title = [title retain];
	
	if ( _title )
		[_pageViewController setTitle:_title];	
}

@end
