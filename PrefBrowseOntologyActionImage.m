//
//  PrefBrowseOntologyActionImage.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefBrowseOntologyActionImage.h"
#import "Language.h"
#import "LanguageManager.h"
#import "BrandManager.h"
#import "SoundTheme.h"
#import "ViewController.h"

#define	LABEL_HEIGHT	30
#define TEXT_HEIGHT		170
#define	STATUS_HEIGHT	20
#define	MOVING_DX		25
#define	TAP_DX			10

@interface PrefBrowseOntologyActionImage (Privates)
-(void)scroll:(int)incr;
-(BOOL)showOnTouch;
-(void)refresh:(BOOL)tapped;
@end

@interface PrefBrowseOntologyActionImage_View : UIView
{
	@public
	PrefBrowseOntologyActionImage*	_item;
	
	CGPoint			beginTouch;
	CGPoint			beginCenter;
	CGPoint			moveTouch;
	BOOL			moving;
	
	float			accumulatedDX;
	
}
@end
@implementation PrefBrowseOntologyActionImage_View

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	//NSLog(@"BEGAN");
	for ( UITouch* touch in touches )
	{
		beginTouch = [touch locationInView:self];
		beginCenter = self.center;
		moving = TRUE;
		accumulatedDX = 0;
		break;
	}
	
	//[_item scroll:1];
	
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//NSLog(@"ENDED");
	if ( !moving )
		return;
	
	for ( UITouch* touch in touches )
	{
		moveTouch = [touch locationInView:self];
		
		float		dx = moveTouch.x - beginTouch.x;
		
		CGPoint		newCenter = self.center;
		newCenter.x += dx;
		accumulatedDX += dx;
		self.center  = newCenter;
		
		int			incr = 0;
		//NSLog(@"dx: %f", accumulatedDX);
		if ( abs(dx) < TAP_DX )
		{
			if ( [_item showOnTouch] )
			{
				[_item refresh:TRUE];
				[_item.soundTheme clicked];
			}
		}
		if ( accumulatedDX > MOVING_DX )
			incr = 1;
		else if ( accumulatedDX < -MOVING_DX )
			incr = -1;
		if ( incr )
		{
			moving = FALSE;
			self.center = beginCenter;
			[_item scroll:incr];
			[_item.soundTheme swiped];
		}		
	}
	
	self.center = beginCenter;
	moving = FALSE;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//NSLog(@"MOVED");
	if ( !moving )
		return;
		
	for ( UITouch* touch in touches )
	{
		moveTouch = [touch locationInView:self];
		
		float		dx = moveTouch.x - beginTouch.x;
		
		CGPoint		newCenter = self.center;
		newCenter.x += dx;
		accumulatedDX += dx;
		self.center  = newCenter;
		
		int			incr = 0;
		//NSLog(@"dx: %f", accumulatedDX);
		if ( accumulatedDX > MOVING_DX )
			incr = 1;
		else if ( accumulatedDX < -MOVING_DX )
			incr = -1;
		if ( incr )
		{
			moving = FALSE;
			self.center = beginCenter;
			[_item scroll:incr];
			[_item.soundTheme swiped];
		}
		
		break;
	}
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"CANCELED");
	self.center = beginCenter;
	moving = FALSE;
}

@end

@implementation PrefBrowseOntologyActionImage
@synthesize imageView = _imageView;
@synthesize labelView = _labelView;
@synthesize textView = _textView;
@synthesize statusView = _statusView;
@synthesize soundTheme = _soundTheme;

-(void)dealloc
{
	[_imageView release];
	[_labelView release];
	[_textView release];
	[_statusView release];
	[_soundTheme release];
	
	[super dealloc];
}

-(void)appeared
{	
	if ( !_soundTheme )
		self.soundTheme = [SoundTheme singleton];

	if ( [self showOnTouch] )
	{
		if ( [_viewController respondsToSelector:@selector(disableScroll)] )
			[_viewController performSelector:@selector(disableScroll)];
	}
	
	[self refresh:FALSE];
	
	[super appeared];
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
		
		CGRect		frame2 = CGRectMake(0.0, height, width, LABEL_HEIGHT);
		height += frame2.size.height;
		self.labelView = [[[UILabel alloc] initWithFrame:frame2] autorelease];
		_labelView.text = @"";
		_labelView.textAlignment = NSTextAlignmentCenter;
		_labelView.font = [[BrandManager currentBrand] globalDefaultFont:AW(28) bold:TRUE];
		_labelView.backgroundColor = [UIColor clearColor];

		CGRect		frame3 = CGRectMake(0.0, height, width, TEXT_HEIGHT);
		height += frame3.size.height;
		_textView = [[[UILabel alloc] initWithFrame:frame3] autorelease];
		_textView.text = @"";
		_textView.textAlignment = NSTextAlignmentCenter;
		_textView.font = [[BrandManager currentBrand] globalDefaultFont:AW(20) bold:TRUE];
		_textView.numberOfLines = 0;
		_textView.contentMode = UIViewContentModeTop; 
		_textView.backgroundColor = [UIColor clearColor];
		
		CGRect		frame4 = CGRectMake(0.0, height, width, STATUS_HEIGHT);
		height += frame4.size.height;
		self.statusView = [[[UILabel alloc] initWithFrame:frame4] autorelease];
		_statusView.text = @"";
		_statusView.textAlignment = NSTextAlignmentCenter;
		_statusView.font = [[BrandManager currentBrand] globalDefaultFont:AW(12) bold:FALSE];
		_statusView.backgroundColor = [UIColor clearColor];
		
		CGRect		frame = CGRectMake(0.0, 0.0, width, height);
		self.control = [[[PrefBrowseOntologyActionImage_View alloc] initWithFrame:frame] autorelease];
		[_control addSubview:_imageView];
		[_control addSubview:_labelView];
		[_control addSubview:_textView];
		[_control addSubview:_statusView];
		((PrefBrowseOntologyActionImage_View*)_control)->_item = self;
	}
	
	return _control;
}

-(float)rowHeight
{
	return _defaultImage.size.height + LABEL_HEIGHT + TEXT_HEIGHT + STATUS_HEIGHT + 20;
}

-(void)refresh
{
	[self refresh:FALSE];
}	

-(void)refresh:(BOOL)tapped
{	
	id<Language>	language = [LanguageManager getNamedLanguage:_uuid];
	NSDictionary*	metaData = [language wordMetaData:[language getWordByIndex:currentWordIndex]];
	if ( metaData )
	{
		if ( ([self showOnTouch] & !tapped) || ![metaData objectForKey:WMD_IMAGE] )
			_imageView.image = _defaultImage;
		else
			_imageView.image = [metaData objectForKey:WMD_IMAGE];
		
		NSString*		word = [metaData objectForKey:WMD_WORD];
		NSString*		title = [metaData objectForKey:WMD_TEXT_TITLE];
		
		_labelView.text = title ? title : word;
		if ( [self showOnTouch] && !tapped)
			_textView.alpha = 0;
		else
			_textView.alpha = 1;
		_textView.text = [metaData objectForKey:WMD_TEXT];
	}
	
	_statusView.text = [NSString stringWithFormat:@"%d/%d", currentWordIndex + 1, [language wordCount]];
	
}

-(void)scroll:(int)incr
{
	id<Language>	language = [LanguageManager getNamedLanguage:_uuid];
	int				wordCount = [language wordCount];
	
	currentWordIndex += incr;
	if ( currentWordIndex >= wordCount )
		currentWordIndex = 0;
	else if ( currentWordIndex < 0 )
		currentWordIndex = wordCount - 1;
	
	[self refresh:FALSE];
}

-(BOOL)showOnTouch
{
	return [_param isEqualToString:@"ShowOnTouch"];
}

@end
