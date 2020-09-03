//
//  PrefMultiValueItem.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefMultiValueItem.h"
#import "Constants.h"
#import "UserPrefs.h"
#import "PrefMultiValueItemViewController.h"
#import <math.h>
#import "L.h"
#import "RTLUtils.h"

@interface PrefMultiValueItem (Privates)
-(NSString*)titleForValue:(NSString*)value;
@end


@implementation PrefMultiValueItem
@synthesize defaultValue = _defaultValue;
@synthesize titles = _titles;
@synthesize values = _values;
@synthesize props = _props;
@synthesize moreSection = _moreSection;
@synthesize emptyValueIsNull;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andTitles:(NSArray*)titles andValues:(NSArray*)values andDefaultStringValue:(NSString*)defaultValue;
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.titles = titles;
		self.values = values;
		self.defaultValue = defaultValue;
		self.value = [UserPrefs getString:self.key withDefault:self.defaultValue];
	}
	return self;
}

-(void)dealloc
{
	[_defaultValue release];
	[_titles release];
	[_values release];
	[_props release];
	[_value release];
	[_moreSection release];
	
	[super dealloc];
}

-(UIView*)control
{
	if ( !_control )
	{
		CGRect		frame = CGRectMake(0.0, 0.0, kMultiValueWidth, kMultiValueHeight);
		UILabel*	labelControl = [[[UILabel alloc] initWithFrame:frame] autorelease];
		
		labelControl.backgroundColor = [UIColor clearColor];
		labelControl.text = [self titleForValue:self.value];
		labelControl.textAlignment = UITextAlignmentRight;
		labelControl.contentMode = UIViewContentModeCenter; 
		
		self.control = labelControl;
	}
	
	return _control;
}

-(BOOL)nests
{
	return TRUE;
}

-(NSString*)value
{
	return _value;
}

-(void)setValue:(NSString*)value
{
	[_value autorelease];
	_value = [value retain];

	if ( self.control )
		[((UILabel*)self.control) setText: RTL([self titleForValue:self.value])];
	
	if ( self.key )
		if ( !_value || (emptyValueIsNull && [_value length] == 0) )
			[UserPrefs removeKey:self.key];
		else
			[UserPrefs setString:self.key withValue:self.value];

	[self wasChanged];
}

-(NSString*)titleForValue:(NSString*)value
{
	int		count = MIN(self.titles.count, self.values.count);
	
	for ( int index = 0 ; index < count ; index++ )
		if ( [value isEqualToString:[self.values objectAtIndex:index]] )
		{
			NSString*		s = [self.titles objectAtIndex:index];
			
			return (s && [s length]) ? s : LOC(@"<empty>");
		}
	
	return @"";
}

-(void)wasSelected:(UIViewController*)inController
{
	PrefMultiValueItemViewController	*next = [[[PrefMultiValueItemViewController alloc] initWithItem:self] autorelease];
	next.moreSection = self.moreSection;
	
	[inController.navigationController pushViewController:next animated:TRUE];
}

-(void)refresh
{
	[_value autorelease];
	_value = [[UserPrefs getString:self.key withDefault:self.defaultValue] retain];

	if ( self.control )
        [((UILabel*)self.control) performSelectorOnMainThread:@selector(setText:) withObject:RTL([self titleForValue:self.value]) waitUntilDone:FALSE];
    /*
		[((UILabel*)self.control) setText: RTL([self titleForValue:self.value])];
     */

	/* NOTE: the more section is not automatically refreshed!
	if ( self.moreSection )
		[self.moreSection refresh];
	*/
}

-(BOOL)detailExistsForValue:(NSString*)value
{
	return FALSE;
}

-(PrefPage*)detailForValue:(NSString*)value
{
	return NULL;
}


@end
