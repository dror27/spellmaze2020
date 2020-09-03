//
//  GameView.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GameLevelView.h"
#import "GameLevel.h"
#import "NSString_Reverse.h"

#import "ScoreWidget.h"
#import "ScoreWidgetView.h"
#import "BrandManager.h"

#import "GridBoard.h"
#import "GridBoardView.h"

#import "NSDictionary_TypedAccess.h"
#import <math.h>
#import "BrandManager.h"
#import "RoleManager.h"
#import "ViewController.h"

@interface GameLevelView (Privates)
-(void)hintImageSustainDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end


@implementation GameLevelView
@synthesize model = _model;
#ifdef GAMELEVELVIEW_MONITOR
@synthesize monitor = _monitor;
#endif
@synthesize symbolsLeft = _symbolsLeft;
@synthesize hintImagePosition;
@synthesize pauseCurtain = _pauseCurtain;

- (id)initWithFrame:(CGRect)frame andModel:(GameLevel*)initModel {
    if (self = [super initWithFrame:frame]) 
	{
		delayFactor = 1.0;
		
		showSymbolsLeftCounter = [[BrandManager currentBrand] globalBoolean:@"skin/props/show-symbols-left-counter" withDefaultValue:FALSE];
		
		self.backgroundColor = [UIColor blackColor];
		
		self.model = initModel;
		
		// has background?
		self.backgroundColor = [UIColor clearColor];
		UIImage*		image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_Background.jpg", _model.uuid]];
		if ( !image && _model.showLanguageBackground )
		{
			NSString*	imagePath = [[_model.language uuidFolder] stringByAppendingPathComponent:@"background.jpg"];
			//NSLog(@"imagePath: %@", imagePath);
			image = [UIImage imageWithContentsOfFile:imagePath];
		}
		if ( image )
		{
			UIImageView*	imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
			
			imageView.image = image;
			[self addSubview:imageView];

			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:10.0];
			imageView.alpha = 0.25;
			[UIView commitAnimations];		
		}
		
		// boards
		int			cellRows = 6, cellColumns = 6;
		float		cellWidth = AW(288.0) / cellColumns, cellHeight = AW(288.0) / cellRows;
		{
			CGRect		rect = {{AW(68),AW(2)}, {cellWidth + 1, cellHeight + 1}};
			[self addSubview:[[_model dispenser] viewWithFrame:rect]];
		}
		{
			if ( !_model.hintBoard )
			{
				CGRect		rect = {{AW(16), cellHeight + AW(8)}, {cellColumns * cellWidth + 1, cellRows * cellHeight + 1}};
				[self addSubview:[[_model board] viewWithFrame:rect]];
			}
			else
			{
				// main board
				CGRect		boardRect = [_model.board suggestedFrame];
				if ( !boardRect.size.width || boardRect.size.height )
				{
					CGRect		rect1 = {{AW(16), cellHeight + AW(8)}, {cellColumns * cellWidth + 1, cellRows * cellHeight + 1}};

					boardRect = rect1;
				}
				CGRect		rect = {{AW(16), cellHeight + AW(8)}, {boardRect.size.width + 1, boardRect.size.height + 1}};
				[self addSubview:[[_model board] viewWithFrame:rect]];
				
				// hint board
				boardRect = [_model.hintBoard suggestedFrame];
				rect.origin.x += boardRect.origin.x;
				rect.origin.y += boardRect.origin.y;
				rect.size.width = boardRect.size.width;
				rect.size.height = boardRect.size.height;
				[self addSubview:[[_model hintBoard] viewWithFrame:rect]];
			}
		}
		
		// score
		{
			CGRect		rect = {{AW(16),AW(360)}, {AW(289),AW(48)}};
            rect.origin.y -= AW(13);
			[self addSubview:[[_model scoreWidget] viewWithFrame:rect]];
		}
		
#ifdef GAMELEVELVIEW_MONITOR
		// monitor
		{
			CGRect		rect = {{0,0}, {AW(100),AW(20)}};
			self.monitor = [[[UILabel alloc] initWithFrame:rect] autorelease];
			_monitor.backgroundColor = [UIColor clearColor];
			_monitor.textColor = [[BrandManager currentBrand] globalGridColor];
			_monitor.font = [[BrandManager currentBrand] globalDefaultFont:AW(14) bold:FALSE];
			_monitor.text = @"";
			[self addSubview:_monitor];		
			//NSLog(@"[GameLevelView-%p] _monitor=%p", self, _monitor);
		}
#endif
		if ( showSymbolsLeftCounter )
		{
			//CGRect		rect = {{188,32}, {46,20}};
			CGRect		rect = {{AW(86),AW(32)}, {AW(46),AW(20)}};
			self.symbolsLeft = [[[UILabel alloc] initWithFrame:rect] autorelease];
			_symbolsLeft.backgroundColor = [UIColor clearColor];
			_symbolsLeft.textColor = [[BrandManager currentBrand] globalGridColor];
			_symbolsLeft.font = [[BrandManager currentBrand] globalDefaultFont:AW(16) bold:TRUE];
			_symbolsLeft.text = @"";
			_symbolsLeft.textAlignment = UITextAlignmentRight;
			[self addSubview:_symbolsLeft];					
		}
		
		self.hintImagePosition = HintImagePositionCorner;
		polaroidMargin = 3;
		polaroidMarginBottom = 0;		
		if ( CHEAT_ON(CHEAT_OLD_IMAGE_HINTS) )
		{
			self.hintImagePosition = HintImagePositionCorner;	
			polaroidMargin = 10;
			polaroidMarginBottom = 25;
		}
		hintImageFrame.origin.x = -1.0;
		
		// pause curtain
		UIImage*	curtain = [[BrandManager currentBrand] globalImage:@"pause-curtain" withDefaultValue:NULL];
		if ( !curtain )
			curtain = [UIImage imageNamed:@"PauseCurtain.png"];
		CGRect		curtainFrame = CGRectMake(0, AW(-curtain.size.height), AW(curtain.size.width), AW(curtain.size.height));
		self.pauseCurtain = [[[UIImageView alloc] initWithFrame:curtainFrame] autorelease];
		_pauseCurtain.image = curtain;
    }
	
	[self becomeFirstResponder];
	
    return self;
}


- (void)dealloc {
	
#ifdef GAMELEVELVIEW_MONITOR
	[_monitor release];
	//NSLog(@"[GameLevelView-%p] _monitor released", self, _monitor);
#endif
	[_symbolsLeft release];
	
	[_pauseCurtain release];
	
    [super dealloc];
}

-(void)wordBlackListed:(NSString*)word
{
	// create the label
	UILabel*		label = [[[UILabel alloc] initWithFrame:self.frame] autorelease];
	label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	label.textColor = [UIColor colorWithWhite:0.75 alpha:0.75];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont boldSystemFontOfSize:AW(54)];
	label.alpha = 0.0;
	label.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
	label.text = [word retain];
	
	// add to view 
	[self insertSubview:label belowSubview:[[_model dispenser] view]];
	
	// build random presentation
	CGPoint		center = {self.frame.size.width/2, self.frame.size.height/2};
	center.x += ((1 - 2 * (rand() / (float)RAND_MAX)) * (0.60 * center.x));
	center.y += ((1 - 2 * (rand() / (float)RAND_MAX)) * (0.60 * center.y));
	float		angle = ((1 - 2 * (rand() / (float)RAND_MAX)) * 1.0); 
														
	[UIView beginAnimations:nil context:label];
	[UIView setAnimationDuration:2.0];
	label.alpha = 1.0;
	label.center = center;
	label.transform = CGAffineTransformRotate(CGAffineTransformScale(CGAffineTransformIdentity, 1.25, 1.25), angle);
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(blackListedInitDidStop:finished:context:)];
	[UIView commitAnimations];		
}

-(void)blackListedInitDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	UILabel*	label = context;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	label.transform = CGAffineTransformScale(label.transform, 0.8, 0.8);
	[UIView commitAnimations];		
}

-(void)showHintImage:(UIImage*)hintImage withEnvelope:(EnvelopeDynamics*)envelope
{
	CGRect		imageFrame;
	
	if ( self.hintImagePosition == HintImagePositionCenter )
	{
		CGRect			boardRect = [[[_model board] view] frame];
		float			centerX = boardRect.origin.x + boardRect.size.width / 2;
		float			centerY = boardRect.origin.y + boardRect.size.height / 2;
		float			maxWidth = boardRect.size.width * 0.7;
		float			maxHeight = boardRect.size.height * 0.7;
		
		imageFrame.size = [hintImage size];
		if ( imageFrame.size.width > maxWidth )
		{
			float		ratio = imageFrame.size.width / maxWidth;
			
			imageFrame.size.width /= ratio;
			imageFrame.size.height /= ratio;
		}
		if ( imageFrame.size.height > maxHeight )
		{
			float		ratio = imageFrame.size.height / maxHeight;
			
			imageFrame.size.width /= ratio;
			imageFrame.size.height /= ratio;
		}
		
		imageFrame.origin.x = centerX - imageFrame.size.width / 2;
		imageFrame.origin.y = centerY - imageFrame.size.height / 2;
	}
	else if ( self.hintImagePosition == HintImagePositionCorner )
	{
		if ( hintImageFrame.origin.x >= 0.0 )
			imageFrame = hintImageFrame;
		else if ( [[_model board] isKindOfClass:[GridBoard class]] )
		{
			GridBoard*		board = (GridBoard*)[_model board];
			int				sizeRows = 3, sizeCols = 3;
			
			NSDictionary*	langProps = [[_model language] props];
			if ( [langProps objectForKey:@"image-aspect"] )
			{
				NSArray*	comps = [[langProps stringForKey:@"image-aspect" withDefaultValue:@"3x3"] componentsSeparatedByString:@"x"];
				if ( [comps count] >= 1 )
					sizeCols = atoi([((NSString*)[comps objectAtIndex:0]) UTF8String]);
				if ( [comps count] >= 2 )
					sizeRows = atoi([((NSString*)[comps objectAtIndex:1]) UTF8String]);
			}
			
			while ( sizeCols >= board.width )
				sizeCols--;
			while ( sizeRows >= board.height )
				sizeRows--;
			if ( sizeCols == 0 )
				sizeCols = 1;
			if ( sizeRows == 0 )
				sizeRows = 1;

			CGRect			r1 = [[board view] cellRectAt:0 andY:board.height - sizeRows];
			CGRect			r1a = [[board view] cellRectAt:1 andY:board.height - sizeRows + 1];
			CGRect			r2 = [[board view] cellRectAt:(sizeCols - 1) andY:board.height - 1];
			float			pad = MIN(r1a.origin.x - (r1.origin.x + r1.size.width), r1a.origin.y - (r1.origin.y + r1.size.height));
			float			width = r2.origin.x - r1.origin.x + r2.size.width + sizeCols * pad;
			float			height = r2.origin.y - r1.origin.y + r2.size.height + sizeRows * pad;
			
			imageFrame = CGRectMake(r1.origin.x - (sizeCols / 2.0) * pad, 
									r1.origin.y - (sizeRows / 2.0) * pad, 
									width,
									height);
			
			imageFrame.origin.x += [[board view] frame].origin.x;
			imageFrame.origin.y += [[board view] frame].origin.y;
			hintImageFrame = imageFrame;
		}
		else	
			hintImageFrame = imageFrame = CGRectMake(AW(9), AW(241), AW(112), AW(112));
	}
	
	CGRect			hintFrame = imageFrame;
	hintFrame.origin.x -= polaroidMargin;
	hintFrame.size.width += (polaroidMargin * 2);
	hintFrame.origin.y -= polaroidMargin;
	hintFrame.size.height += (polaroidMargin * 2 + polaroidMarginBottom);
	UIView*			hintView = [[[UIView alloc] initWithFrame:hintFrame] autorelease];
	hintView.backgroundColor = [[BrandManager currentBrand] globalColor:@"hint-polaroid-frame" withDefaultValue:[UIColor whiteColor]];
	[self addSubview:hintView];
	
	imageFrame.origin.x = polaroidMargin;
	imageFrame.origin.y = polaroidMargin;
	UIImageView*	imageView = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.image = hintImage;
	[hintView addSubview:imageView];
	
	NSArray*		context = [[NSArray arrayWithObjects:hintView, envelope, NULL] retain];
	
	/*
	NSLog(@"showHintImage: %f %f %f %f %f %f",
		  envelope->points[EnvelopeDynamicsPointTypeAttack].duration,
		  envelope->points[EnvelopeDynamicsPointTypeAttack].alpha,
		  envelope->points[EnvelopeDynamicsPointTypeSustain].duration,
		  envelope->points[EnvelopeDynamicsPointTypeSustain].alpha,
		  envelope->points[EnvelopeDynamicsPointTypeDecay].duration,
		  envelope->points[EnvelopeDynamicsPointTypeDecay].alpha);
	*/
	
	hintView.alpha = 0.0;
	if ( self.hintImagePosition == HintImagePositionCorner )
	{
		CGRect		outOfScreenHintFrame = hintFrame;
		outOfScreenHintFrame.origin.x = -hintFrame.size.width;
		
		hintView.frame = outOfScreenHintFrame;
	}	
	if ( self.hintImagePosition == HintImagePositionCenter )
		hintView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
	else if ( self.hintImagePosition == HintImagePositionCorner )
	{
		CGRect		outOfScreenHintFrame = hintFrame;
		outOfScreenHintFrame.origin.x = -hintFrame.size.width;
			
		hintView.frame = outOfScreenHintFrame;
	}	
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:envelope->points[EnvelopeDynamicsPointTypeAttack].duration * delayFactor];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hintImageAttackDidStop:finished:context:)];
	hintView.alpha = envelope->points[EnvelopeDynamicsPointTypeAttack].alpha;
	if ( self.hintImagePosition == HintImagePositionCenter )
		hintView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.2, 1.2), 0.25);
	else if ( self.hintImagePosition == HintImagePositionCorner )
	{
		hintView.transform = CGAffineTransformIdentity;
		hintView.frame = hintFrame;
	}
	[UIView commitAnimations];			
}

-(void)hintImageAttackDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//NSLog(@"hintImageAttackDidStop:");
	
	UIView*					hintView = [((NSArray*)context) objectAtIndex:0];
	EnvelopeDynamics*		envelope = [((NSArray*)context) objectAtIndex:1];
	
	if ( hintView.alpha != envelope->points[EnvelopeDynamicsPointTypeSustain].alpha )
	{	
		[UIView beginAnimations:nil context:context];
		[UIView setAnimationDuration:envelope->points[EnvelopeDynamicsPointTypeSustain].duration * delayFactor];
		[UIView setAnimationDelegate:self];
		hintView.alpha = envelope->points[EnvelopeDynamicsPointTypeSustain].alpha;
		[UIView setAnimationDidStopSelector:@selector(hintImageSustainDidStop:finished:context:)];
		[UIView commitAnimations];		
	}
	else if ( envelope->points[EnvelopeDynamicsPointTypeSustain].duration <= 0.0 )
		[self hintImageSustainDidStop:animationID finished:finished context:context];
	else
	{
		[self performSelector:@selector(hintImageSustainDidStop:) withObject:context 
											afterDelay:envelope->points[EnvelopeDynamicsPointTypeSustain].duration * delayFactor];
	}
}

-(void)hintImageSustainDidStop:(void *)context 
{
	[self hintImageSustainDidStop:@"" finished:[NSNumber numberWithInt:0] context:context];
}

-(void)hintImageSustainDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//NSLog(@"hintImageSustainDidStop:");

	UIView*					hintView = [((NSArray*)context) objectAtIndex:0];
	EnvelopeDynamics*		envelope = [((NSArray*)context) objectAtIndex:1];
		
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationDuration:envelope->points[EnvelopeDynamicsPointTypeDecay].duration * delayFactor];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hintImageDecayDidStop:finished:context:)];
	hintView.alpha = envelope->points[EnvelopeDynamicsPointTypeDecay].alpha;
	if ( self.hintImagePosition == HintImagePositionCenter )
		hintView.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.0, 1.0), 0.25);
	else if ( self.hintImagePosition == HintImagePositionCorner )
	{
		hintView.transform = CGAffineTransformIdentity;

		CGRect		outOfScreenHintFrame = hintView.frame;
		outOfScreenHintFrame.origin.x = -hintView.frame.size.width;
		
		hintView.frame = outOfScreenHintFrame;
	}
	[UIView commitAnimations];			
}

-(void)hintImageDecayDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	//NSLog(@"hintImageDecayDidStop:");

	UIView*					hintView = [((NSArray*)context) objectAtIndex:0];
	
	[hintView removeFromSuperview];
	
	[((NSArray*)context) release];
}

-(void)updateMonitor:(NSString*)text
{
#ifdef GAMELEVELVIEW_MONITOR
	_monitor.text = text;
#endif
}

-(void)updateSymbolsLeft:(NSString*)text
{
	[_symbolsLeft setText:text];
}


-(void)fineTick
{
	
}

-(void)tick
{
}

-(void)updatePauseCurtain
{
	GameLevelState		state = [_model state];
	
	if ( state == PAUSED || state == SUSPENDED )
	{
		if ( !pauseCurtainShown )
		{
			CGPoint		newCenter = _pauseCurtain.center;
			newCenter.y = _pauseCurtain.frame.size.height / 2 - AW(32);

			[self addSubview:_pauseCurtain];
			[self bringSubviewToFront:[[_model scoreWidget] view]];
			pauseCurtainShown = TRUE;			
			
			// show curtain
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.2];
			_pauseCurtain.center = newCenter;
			[UIView commitAnimations];	
		}
	}
	else
	{
		if ( pauseCurtainShown )
		{
			CGPoint		newCenter = _pauseCurtain.center;
			newCenter.y = - (_pauseCurtain.image.size.height / 2);
			
			// remove curtain
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.2];
			[UIView setAnimationDelegate:self];
			_pauseCurtain.center = newCenter;
			[UIView setAnimationDidStopSelector:@selector(pauseCurtainHideDidStop:finished:context:)];
			[UIView commitAnimations];	
		}
	}
}

-(void)pauseCurtainHideDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[_pauseCurtain removeFromSuperview];
	pauseCurtainShown = FALSE;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event 
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) 
	{
		[[_model soundTheme] pieceHinted];
		[_model shaken];
    }
}


@end
