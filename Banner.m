//
//  Banner.m
//  Board3
//
//  Created by Dror Kessler on 9/10/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import <UIKit/UIImageView.h>
#import <UIKit/UIApplication.h>
#import "Banner.h"

@interface Banner (Private)
-(void)animate;
@end


@implementation Banner
@synthesize imageView = _imageView;
@synthesize link = _link;

-(void)dealloc
{
	[_imageView release];
	[_link release];
	
	[super dealloc];
}

extern CGRect  globalFrame;

-(void)placeOnView:(UIView*)view atY:(float)y
{
	CGRect		bannerFrame = _imageView.frame;
	bannerFrame.origin.y = y;
    bannerFrame.origin.x = (globalFrame.size.width - bannerFrame.size.width) / 2.0;
	self.backgroundColor = [UIColor clearColor];
	
	self.frame = bannerFrame;
	bannerFrame.origin = CGPointMake(0,0);
	_imageView.frame = bannerFrame;
	[self addSubview:_imageView];
	[view addSubview:self];
	[view sendSubviewToBack:self];
	
	[self animate];
}

-(void)removeFromView;
{
	[self removeFromSuperview];
	[_imageView removeFromSuperview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"Banner: touchesBegan ...");
	
	if ( _link )
	{
		NSURL*	url = [NSURL URLWithString:_link];
		
		[[UIApplication sharedApplication] openURL:url];
	}
}

-(void)animate
{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(showAnimationDidStop:finished:context:)];
	self.transform = CGAffineTransformMakeScale(1.3, 1.3);
	[UIView commitAnimations];			
}

-(void)showAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];			
}



@end
