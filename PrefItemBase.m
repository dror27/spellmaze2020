//
//  PrefItemBase.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefItemBase.h"
#import "UserPrefs.h"


@implementation PrefItemBase
@synthesize label = _label;
@synthesize key = _key;
@synthesize viewController = _viewController;
@synthesize control = _control;
@synthesize relatedKey = _relatedKey;
@synthesize labelLabel = _labelLabel;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key
{
	if ( self = [super init] )
	{
		self.label = label;
		self.key = key;
		
		if ( self.key )
			[UserPrefs addKeyDelegate:self forKey:self.key];
	}
	return self;
}

-(void)dealloc
{
	if ( self.key )
		[UserPrefs removeKeyDelegate:self forKey:self.key];
	
	[_label release];
	[_key release];
	[_control release];
	[_relatedKey release];
	[_labelLabel release];
	
	[super dealloc];
}

-(BOOL)nests
{
	return FALSE;
}

-(BOOL)selectable
{
	return [self nests];
}

-(void)wasSelected:(UIViewController*)inController
{
	
}

-(float)rowHeight
{
	return 0.0;
}

-(void)wasChanged
{
	if ( _relatedKey )
		[UserPrefs fireDelegatesForKey:_relatedKey];
}

// for now ...
-(id)copyWithZone:(NSZone *)zone
{
	return [self retain];
}

-(void)refresh
{
	[_labelLabel setText:_label];
}

-(void)appeared
{
	
}

-(void)disappeared
{
	
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	[self refresh];
}

-(void)setLabel:(NSString*)label
{
	[_label autorelease];
	_label = [label retain];
	
	[_labelLabel setText:_label];
}

-(BOOL)sourceLabel
{
	return FALSE;
}

-(BOOL)startup
{
	return FALSE;
}
@end
