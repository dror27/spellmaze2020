//
//  ImageSequenceMediaView.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/5/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "ImageSequenceMediaView.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"
#import "SystemUtils.h"

@interface ImageSequenceMediaView (Privates)
-(void)reloadPlayer;
@end



@implementation ImageSequenceMediaView
@synthesize imageView = _imageView;
@synthesize props = _props;
@synthesize posterImage = _posterImage;
@synthesize folder = _folder;
@synthesize state;
@synthesize loadingView = _loadingView;
@synthesize player = _player;

-(id)initWithFrame:(CGRect)frame andFolder:(NSString*)folder andProps:(NSDictionary*)props
{
	if ( self = [super initWithFrame:frame] )
	{
		// create image view
		CGRect		imageFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		self.imageView = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
		
		// load props
		self.folder = folder;
		self.props = props;
		self.posterImage = [UIImage imageWithContentsOfFile:[_folder stringByAppendingPathComponent:[_props stringForKey:@"poster-image" withDefaultValue:@"images/poster.jpg"]]];
		_imageView.image = _posterImage;
		_imageView.contentMode = UIViewContentModeCenter;
		
		// setup loading view
		self.loadingView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
		_loadingView.center = CGPointMake(imageFrame.size.width / 2, imageFrame.size.height / 2);
		[self addSubview:_loadingView];
		[_loadingView startAnimating];
		
		// read images in the background
		state = ImageSequenceMediaViewStateLoading;
		[SystemUtils threadWithTarget:self selector:@selector(loadThread) object:self];
		
		// load hidden
		_imageView.alpha = 0.1;
		[self addSubview:_imageView];
		
		// sound?
		[self reloadPlayer];
	}
	return self;
}

-(void)dealloc
{
	[_imageView release];
	[_props release];
	[_posterImage release];
	[_folder release];
	[_loadingView release];
	[_player release];
	
	[super dealloc];
}

-(void)loadThread
{
	NSAutoreleasePool*		pool = [[NSAutoreleasePool alloc] init];

	// read images in
	NSString*		imageFormat = [_props stringForKey:@"image-format" withDefaultValue:@"images/image%02d.jpg"];
	int				imageFrames = [_props integerForKey:@"image-frames" withDefaultValue:10];
	int				imageFPS = [_props integerForKey:@"image-fps" withDefaultValue:5];
	NSMutableArray* images = [NSMutableArray array];
	for ( int index = 1 ; index <= imageFrames ; index++ )
	{
		NSString*	path = [_folder stringByAppendingPathComponent:[NSString stringWithFormat:imageFormat, index]];
		UIImage*	image = [UIImage imageWithContentsOfFile:path];
		
		[images addObject:image];
	}	
	_imageView.animationImages = images;
	_imageView.animationDuration = imageFrames / (float)imageFPS / 1.0;
	_imageView.animationRepeatCount = [_props integerForKey:@"image-repeat-count" withDefaultValue:1];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(loadedAnimationDidStop:finished:context:)];
	_imageView.alpha = 1.0;
	_loadingView.alpha = 0.0;
	[UIView commitAnimations];		
		
	@synchronized (self)
	{
		state = ImageSequenceMediaViewStateReady;
		if ( playPending )
			[self performSelectorOnMainThread:@selector(play) withObject:self waitUntilDone:FALSE];
	}
	
	[pool release];
}

-(void)loadedAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[_loadingView removeFromSuperview];
	self.loadingView = NULL;
}

-(void)play
{
	@synchronized (self)
	{
		if ( state == ImageSequenceMediaViewStateReady )
		{
			[_player play];
			[_imageView startAnimating];
			state = ImageSequenceMediaViewStatePlaying;
			[self performSelector:@selector(checkPlayDone) withObject:self afterDelay:0.2];
		}
		else if ( state != ImageSequenceMediaViewStatePlaying )
			playPending = TRUE;
	}
}

-(void)stop
{
	@synchronized (self)
	{
		if ( state == ImageSequenceMediaViewStatePlaying )
		{
			[_player stop];
			[self reloadPlayer];
			
			[_imageView stopAnimating];
			
			state = ImageSequenceMediaViewStateReady;
		}
	}	
}

-(void)checkPlayDone
{
	@synchronized (self)
	{
		if ( state == ImageSequenceMediaViewStatePlaying && ![_imageView isAnimating] )
		{
			state = ImageSequenceMediaViewStateReady;
			_imageView.image = _posterImage;
		}
		else
		{
			[self performSelector:@selector(checkPlayDone) withObject:self afterDelay:0.2];			
		}
	}
}

-(ImageSequenceMediaViewState)state
{
	if ( state == ImageSequenceMediaViewStatePlaying && ![_imageView isAnimating] )
		state = ImageSequenceMediaViewStateReady;
	
	return state;
}

-(void)reloadPlayer
{
	if ( [_props objectForKey:@"sound"] )
	{
		NSString*	path = [_folder stringByAppendingPathComponent:[_props objectForKey:@"sound"]];
		NSURL*		url = [[[NSURL alloc] initFileURLWithPath:path isDirectory:FALSE] autorelease];
		NSError*	error = NULL;
		
		self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
		if ( error )
			NSLog(@"ERROR - %@", error);
	}	
}

@end
