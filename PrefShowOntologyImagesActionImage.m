//
//  PrefShowOntologyImagesActionItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefShowOntologyImagesActionImage.h"
#import "Language.h"
#import "LanguageManager.h"
#import "BrandManager.h"
#import	<QuartzCore/QuartzCore.h>
#import "ViewController.h"

#define	LABEL_HEIGHT	30


@implementation PrefShowOntologyImagesActionImage
@synthesize imageView = _imageView;
@synthesize labelView = _labelView;
@synthesize language = _language;

-(void)dealloc
{
	[_imageView release];
	[_labelView release];
	[_language release];
	
	[super dealloc];
}

-(void)appeared
{
	[self refresh];

	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextWord:) object:self];
	[self performSelector:@selector(nextWord:) withObject:self afterDelay:0.5];
	
	[super appeared];
}

-(void)disappeared
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextWord:) object:self];

	[super disappeared];
}

-(UIView*)control
{
	if ( !_control )
	{
		float			height = 0;
		float			width = 280;
		
		self.image = self.defaultImage;
		CGRect		frame1 = CGRectMake((width - _image.size.width) / 2, 0.0, _image.size.width, _image.size.height);
		height += frame1.size.height;
		self.imageView = [[[UIImageView alloc] initWithFrame:frame1] autorelease];
		self.imageView.image = _image;
		self.imageView.contentMode = UIViewContentModeCenter;
		self.imageView.layer.masksToBounds = YES;
		
		CGRect		frame2 = CGRectMake(0.0, height, width, LABEL_HEIGHT);
		height += frame2.size.height;
		self.labelView = [[[UILabel alloc] initWithFrame:frame2] autorelease];
		_labelView.text = @"";
		_labelView.textAlignment = NSTextAlignmentCenter;
		_labelView.font = [[BrandManager currentBrand] globalDefaultFont:AW(22) bold:TRUE];
		_labelView.backgroundColor = [UIColor clearColor];
				
		CGRect		frame = CGRectMake(0.0, 0.0, width, height);
		self.control = [[[UIView alloc] initWithFrame:frame] autorelease];
		[_control addSubview:_imageView];
		[_control addSubview:_labelView];
	}
	
	return _control;
}

-(float)rowHeight
{
	return _defaultImage.size.height + LABEL_HEIGHT + 20;
}

-(void)refresh
{
	self.language = [LanguageManager getNamedLanguage:_uuid];
	wordIndex = 0;
	
	if ( _language )
	{
		// put first word for now
		NSString*		word = [_language getWordByIndex:wordIndex];
		UIImage*		image = [_language wordImage:word];
		if ( !image )
			image = _defaultImage;
		
		_imageView.image = image;
		_labelView.text = word;
	}
}

-(void)nextWord:(id)sender
{
	wordIndex++;
	if ( wordIndex >= [_language wordCount] )
		wordIndex = 0;
	
	NSString*		word = [_language getWordByIndex:wordIndex];
	UIImage*		image = [_language wordImage:word];
	if ( !image )
		image = _defaultImage;
	
	_imageView.image = image;
	_labelView.text = word;
	
	
	[self performSelector:@selector(nextWord:) withObject:self afterDelay:0.5];	
}

@end
