//
//  ImagePieceDecorator.m
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ImagePieceDecorator.h"
#import "ViewController.h"


@implementation ImagePieceDecorator
@synthesize image = _image;
@synthesize imageView = _imageView;
@synthesize xPos = _xPos;
@synthesize yPos = _yPos;
@synthesize bounce = _bounce;

-(id)init
{
	if ( self = [super init] )
	{
		_bounce = TRUE;
	}
	return self;
}

-(id)retain
{
	return [super retain];
}

-(void)dealloc
{
	[_image release];
	[_imageView release];
	
	[super dealloc];
}

-(void)decorate:(id<Piece>)piece
{
	// establish parent view
	UIView*		parent = [piece view];
	
	// establish position within parent
	float		x = parent.frame.size.width * _xPos;
	float		y = parent.frame.size.height * _yPos;
	CGRect		frame = CGRectMake(x, y, AW(_image.size.width), AW(_image.size.height));
	
	// view image view and place it
	self.imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
	_imageView.center = CGPointMake(x, y);
	_imageView.image = _image;
	_imageView.transform = CGAffineTransformMakeScale(0.5, 0.5);
	[parent addSubview:_imageView];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	_imageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
	[UIView commitAnimations];	
	
	if ( _bounce )
	{
		[self performSelector:@selector(startBounce:) withObject:self afterDelay:5.0];
	}
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	_imageView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];			
}
	
-(void)startBounce:(id)sender
{
	if ( _imageView )
	{
		CGPoint		center = _imageView.center;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(bounceUpDidStop:finished:context:)];
		_imageView.center = CGPointMake(center.x, center.y - 10);
		[UIView commitAnimations];	
	}
}

-(void)bounceUpDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	if ( _imageView )
	{
		CGPoint		center = _imageView.center;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(bounceDownDidStop:finished:context:)];
		_imageView.center = CGPointMake(center.x, center.y + 10);
		[UIView commitAnimations];
	}
}

-(void)bounceDownDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	if ( _imageView )
		[self performSelector:@selector(startBounce:) withObject:self afterDelay:5.0];
}


-(void)undecorate
{
	[_imageView removeFromSuperview];
	self.imageView = NULL;
}

@end
