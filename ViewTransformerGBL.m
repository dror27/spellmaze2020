//
//  ViewTransformerGBL.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/17/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "ViewTransformerGBL.h"
#import "UserPrefs.h"

//#define	DUMP

@interface ViewTransformerGBL (Privates)
-(void)rotate:(SEL)selector;
-(void)atEnd;
-(void)flip:(BOOL)flippedState;
@end


@implementation ViewTransformerGBL
@synthesize rotationSlices;
@synthesize rotationEvent = _rotationEvent;
@synthesize resetAtEnd;
@synthesize accelerometer = _accelerometer;
@synthesize xFilter = _xFilter;
@synthesize yFilter = _yFilter;
@synthesize followDevice;
@synthesize deviceLPF;
@synthesize deviceSlices;

static double pi;


-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super initWithBoard:board] )
	{
		rotationSlices = 4;
		self.rotationEvent = @"validWordSelected:";
		resetAtEnd = TRUE;
		followDevice = FALSE;
		deviceSlices = 0;
		pi = acos(0) * 2;
	}
	return self;
}


-(void)dealloc
{
	[_rotationEvent release];
	
	[_xFilter release];
	[_yFilter release];
	
	if ( [_accelerometer delegate] == self )
	{	
		[_accelerometer setDelegate:nil];
#ifdef DUMP
		NSLog(@"setDelegate: nil");
#endif
	}
	
	[_accelerometer release];
	
	[super dealloc];
}

-(void)setFollowDevice:(BOOL)followDevice_
{
	followDevice = followDevice_;
	
	if ( followDevice )
	{
		self.xFilter = [[[LowPassFilter alloc] initWithDepth:deviceLPF] autorelease];
		self.yFilter = [[[LowPassFilter alloc] initWithDepth:deviceLPF] autorelease];			
		
		self.accelerometer = [UIAccelerometer sharedAccelerometer];
		[_accelerometer setDelegate:self];
#ifdef DUMP
		NSLog(@"setDelegate: %@", self);
#endif
		[_accelerometer setUpdateInterval:0.1];		
	}
	else
	{
		if ( [_accelerometer delegate] == self )
		{	
			[_accelerometer setDelegate:nil];
#ifdef DUMP
			NSLog(@"setDelegate: nil");
#endif
		}		
	}
}

-(void)setDeviceLPF:(int)deviceLPF_
{
	deviceLPF = deviceLPF_;
	
	self.xFilter = [[[LowPassFilter alloc] initWithDepth:deviceLPF] autorelease];
	self.yFilter = [[[LowPassFilter alloc] initWithDepth:deviceLPF] autorelease];			
	
}

-(void)pieceDispensed:(id<Piece>)piece
{
	[self rotate:_cmd];
}

-(void)pieceSelected:(id<Piece>)piece
{
	[self rotate:_cmd];
}

-(void)pieceReselected:(id<Piece>)piece
{
	[self rotate:_cmd];
}

-(void)validWordSelected:(NSString*)word
{
	[self rotate:_cmd];
	
	
}

-(void)invalidWordSelected:(NSString*)word
{
	[self rotate:_cmd];
	
}

-(void)wordSelectionCanceled
{
	[self rotate:_cmd];
}

-(void)onGameTimer
{
	[self rotate:_cmd];
	
#ifdef DUMP
	NSLog(@"%@", [_accelerometer delegate]);
#endif
}

-(void)onFineGameTimer
{
	[self rotate:_cmd];
}

-(void)onGameWon
{
	[self atEnd];
}

-(void)onGameOver
{
	[self atEnd];
}

-(void)rotate:(SEL)selector
{
	NSString*	selectorName = [NSString stringWithCString:sel_getName(selector)];
	
	if ( [_rotationEvent isEqualToString:selectorName] )
	{
		if ( rotationSlices > 0 )
		{
			double		rotationStep = acos(0.0) * 4 / rotationSlices;
			
			rotation += rotationStep;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.2];
			[_board view].transform = CGAffineTransformMakeRotation(rotation);
			[UIView commitAnimations];		
		}
		else
		{
			[self flip:(flipped = !flipped)];
		}
	}
}

-(void)atEnd
{
	ended = TRUE;
	if ( resetAtEnd )
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.2];
		[_board view].transform = CGAffineTransformIdentity;
		[UIView commitAnimations];		
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if ( !ended )
	{
		double	x = [_xFilter pass:acceleration.x];
		double	y = [_yFilter pass:acceleration.y];
		
		double	angle = atan2(y, x);
#ifdef DUMP
		NSLog(@"angle: %f", angle);
#endif
		
		// slice the angle?
		if ( deviceSlices )
		{
			int		slice = round((angle / (2*pi)) * deviceSlices);
			angle = (slice / (double)deviceSlices) * 2*pi;
		}
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.1];
		[_board view].transform = CGAffineTransformMakeRotation(-angle - pi/2 + rotation);
		[UIView commitAnimations];		
	}
}

-(void)flip:(BOOL)flippedState
{
	if ( flippedState )
	{
		 [_board view].transform = CGAffineTransformTranslate(
		 CGAffineTransformScale(CGAffineTransformMakeTranslation([_board view].frame.size.width, 0), -1.0, 1.0),
		 [_board view].frame.size.width, 0);
		 [UIView beginAnimations:nil context:nil];
		 [UIView setAnimationDuration:0.4];
		 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[_board view] cache:NO];
		 [UIView commitAnimations];		
	}
	else
	{
		 [_board view].transform = CGAffineTransformIdentity;
		 [UIView beginAnimations:nil context:nil];
		 [UIView setAnimationDuration:0.4];
		 [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[_board view] cache:NO];
		 [UIView commitAnimations];		
	}
}

@end
