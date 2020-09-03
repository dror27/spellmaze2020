//
//  PrefImageSequenceItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefImageSequenceItem.h"
#import "NSDictionary_TypedAccess.h"


@interface PrefImageSequenceItem (Privates)
-(void)fetch;
@end


@implementation PrefImageSequenceItem
@synthesize folder = _folder;
@synthesize props = _props;
@synthesize mediaView = _mediaView;
@synthesize text = _text;


-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andFolder:(NSString*)folder andProps:(NSDictionary*)props
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.folder = folder;
		self.props = props;
	}
	return self;
}

-(void)dealloc
{
	[_folder release];
	[_props release];
	[_text release];
	
	[super dealloc];
}

-(UIView*)control
{
	if ( !_control )
	{
		[self fetch];
		
		if ( [_text length] )
		{
			// create containing frame
			CGRect			frame = [_mediaView frame];
			frame.size.width += textWidth;
			UIView*			view = [[[UIView alloc] initWithFrame:frame] autorelease];
			
			// create text
			frame = [_mediaView frame];
			frame.origin.x = frame.size.width;
			frame.size.width = textWidth;
			UITextView*		textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
			textView.editable = FALSE;
			textView.text = _text;
			
			// insert into view
			[view addSubview:_mediaView];
			[view addSubview:textView];
			self.control = view;
		}
		else
		{
			self.control = _mediaView;
		}
		
		[_mediaView performSelector:@selector(play) withObject:self afterDelay:0.2];
	}
	
	return _control;
}

-(BOOL)selectable
{
	return TRUE;
}

-(void)appeared
{
	[_mediaView play];
}

-(void)disappeared
{
	[_mediaView stop];
}

-(void)wasSelected:(UIViewController*)inController
{
	[_mediaView play];
}

-(float)rowHeight
{
	[self fetch];
	
	if ( _mediaView )
		return height + 10;
	else
		return [super rowHeight];
}

-(void)fetch
{
	if ( !_mediaView )
	{
		width = [_props floatForKey:@"width" withDefaultValue:150];
		height = [_props floatForKey:@"height" withDefaultValue:205];
		textWidth = [_props floatForKey:@"text-width" withDefaultValue:150];
		self.text = [_props stringForKey:@"text" withDefaultValue:NULL];
		
		CGRect	frame = CGRectMake(0, 0, width, height);
		
		self.mediaView = [[[ImageSequenceMediaView alloc] initWithFrame:frame andFolder:_folder andProps:_props] autorelease];
	}
}



@end
