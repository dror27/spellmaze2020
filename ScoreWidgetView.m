//
//  ScoreWidgetView.m
//  Board3
//
//  Created by Dror Kessler on 6/2/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ScoreWidgetView.h"
#import "ScoreWidget.h"
#import "Piece.h"
#import "GridBoard.h"
#import "GridBoardView.h"
#import "SymbolPiece.h"
#import "SoundTheme.h"
#import "UserPrefs.h"
#import <math.h>
#import "BrandManager.h"
#import "RoleManager.h"
#import "L.h"
#import "RTLUtils.h"
#import "ViewController.h"

@interface ScoreWidgetView (Privates)
+(UIImage*)buildPauseImage;
+(UIImage*)buildPlayImage;
+(UIImage*)buildHintImage;
-(void)animateSelection:(UIView*)view;
@end

extern NSMutableDictionary*	globalData;
#define	PLAYIMAGE_KEY		@"ScoreWidgetView_playImage"
#define	PAUSEIMAGE_KEY		@"ScoreWidgetView_pauseImage"
#define	HINTIMAGE_KEY		@"ScoreWidgetView_hintImage"

#define						WALLET_ITEM_WIDTH	AW(24)
#define						WALLET_ITEM_HEIGHT	AW(24)
#define						WALLET_ITEM_PADDING	AW(2)

#define						LABEL_ITEM_WIDTH	AW(16)
#define						LABEL_ITEM_HEIGHT	AW(16)
#define						LABEL_ITEM_PADDING	AW(2)

@implementation ScoreWidgetView
@synthesize model = _model;
@synthesize scoreNumberFormatter = _scoreNumberFormatter;
@synthesize score = _score;
@synthesize message = _message;
@synthesize message1 = _message1;
@synthesize message2 = _message2;
@synthesize playState = _playState;
@synthesize gameAction = _gameAction;
@synthesize playImage = _playImage;
@synthesize pauseImage = _pauseImage;
@synthesize hintImage = _hintImage;
@synthesize progress1Color = _progress1Color;
@synthesize progress2Color = _progress2Color;
@synthesize progress3Color = _progress3Color;
@synthesize walletView = _walletView;
@synthesize limitationsLabel = _limitationsLabel;
@synthesize wordCountLabel = _wordCountLabel;
@synthesize progress1Image = _progress1Image;
@synthesize progress2Image = _progress2Image;
@synthesize progress3Image = _progress3Image;

-(id)initWithFrame:(CGRect)frame andModel:(ScoreWidget*)initModel 
{
    if (self = [super initWithFrame:frame]) {
		
		Brand*		brand = [BrandManager currentBrand];
		
		self.model = initModel;
		
		self.scoreNumberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		[_scoreNumberFormatter setGroupingSize:3];
		[_scoreNumberFormatter setGroupingSeparator:@","];
		[_scoreNumberFormatter setUsesGroupingSeparator:TRUE];
		
		
		CGRect		frameRect = {{AW(2),AW(2)}, {[self frame].size.width-AW(4), [self frame].size.height-AW(4)}};

		// reduce by 32 from each side for controls ...
		frameRect.origin.x += AW(32);
		frameRect.size.width -= AW(64);
		
		self.score = [[[UILabel alloc] initWithFrame:frameRect] autorelease];
		_score.textColor = [brand globalTextColor];
		_score.backgroundColor = [UIColor clearColor];
		_score.textAlignment = NSTextAlignmentCenter;
		_score.font = [brand globalDefaultFont:AW(32) bold:FALSE];
		[self addSubview:_score];

		self.message = [[[UILabel alloc] initWithFrame:frameRect] autorelease];
		_message.textColor = [brand globalTextColor];
		_message.backgroundColor = [UIColor clearColor];
        _message.textAlignment = NSTextAlignmentCenter;
        _message.textAlignment = NSTextAlignmentCenter;
		_message.font = [brand globalDefaultFont:AW(32) bold:TRUE];
		_message.alpha = 0.0;
		_message.adjustsFontSizeToFitWidth = YES; 
		[self addSubview:_message];
		
		CGRect	frame1 = frameRect;
		frame1.origin.y -= AW(2);
		frame1.size.height = frame.size.height * 2 / 3;
		self.message1 = [[[UILabel alloc] initWithFrame:frame1] autorelease];
		_message1.textColor = _message.textColor;
		_message1.backgroundColor = _message.backgroundColor;
		_message1.textAlignment = _message.textAlignment;
		_message1.font = [brand globalDefaultFont:AW(24) bold:TRUE];
		_message1.alpha = 0.0;
		_message1.adjustsFontSizeToFitWidth = YES; 
		[self addSubview:_message1];

		CGRect	frame2 = frameRect;
		frame2.size.height = frame.size.height - frame1.size.height;
		frame2.origin.y = frame1.origin.y + frame1.size.height - AW(2);
		self.message2 = [[[UILabel alloc] initWithFrame:frame2] autorelease];
		_message2.textColor = _message.textColor;
		_message2.backgroundColor = _message.backgroundColor;
		_message2.textAlignment = _message.textAlignment;
		_message2.font = [brand globalDefaultFont:AW(14) bold:FALSE];
		_message2.alpha = 0.0;
		_message2.adjustsFontSizeToFitWidth = YES; 
		[self addSubview:_message2];
		
		// wallet
		CGRect	frame3 = CGRectMake(WALLET_ITEM_WIDTH / 4, -(WALLET_ITEM_HEIGHT / 2), [self frame].size.width - WALLET_ITEM_WIDTH / 2, WALLET_ITEM_HEIGHT);
		self.walletView = [[[UIView alloc] initWithFrame:frame3] autorelease];
		_walletView.backgroundColor = [UIColor clearColor];
		walletVersion = -1;
		[self addSubview:_walletView];		
		
		[self updateScore];
		[self updateProgress];
		
		// limitations
		/*
		CGRect	frame4 = CGRectMake(LABEL_ITEM_WIDTH / 4, [self frame].size.height -(LABEL_ITEM_HEIGHT / 2), [self frame].size.width - LABEL_ITEM_WIDTH / 2, LABEL_ITEM_HEIGHT);
		self.limitationsLabel = [[[UILabel alloc] initWithFrame:frame4] autorelease];
		_limitationsLabel.backgroundColor = [UIColor greenColor];
		_limitationsLabel.text = @"1234";
		_limitationsLabel.font = [brand globalDefaultFont:AW(10) bold:FALSE];
		[self addSubview:_limitationsLabel];		
		 */
		
		// play/pause button
		CGRect			playStateRect = CGRectMake(AW(3), AW(3), AW(32), frame.size.height - AW(3));
		self.playState = [[[UIButton alloc] initWithFrame:playStateRect] autorelease];
		_playState.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_playState.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		//[_playState setTitle:@"?" forState:UIControlStateNormal];	
		//[_playState setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		self.playImage = [ScoreWidgetView buildPlayImage];
		self.pauseImage = [ScoreWidgetView buildPauseImage];
		_playState.alpha = 0.0;		// initialy hidden
		[_playState addTarget:self action:@selector(playStateTouched) forControlEvents:UIControlEventTouchDown];
		[self addSubview:_playState];
		[self updatePlayState];

		// gameAction button
		CGRect			gameActionRect = CGRectMake(frame.size.width - AW(3) - AW(32), AW(3), AW(32), frame.size.height - AW(3));
		self.gameAction = [[[UIButton alloc] initWithFrame:gameActionRect] autorelease];
		_gameAction.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_gameAction.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		//[_gameAction setTitle:@"?" forState:UIControlStateNormal];	
		//[_gameAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		self.hintImage = [ScoreWidgetView buildHintImage];
		_gameAction.alpha = 0.0;		// initialy hidden
		[_gameAction addTarget:self action:@selector(gameActionTouched) forControlEvents:UIControlEventTouchDown];
		//[_gameAction addTarget:self action:@selector(gameActionTouched2) forControlEvents:UIControlEventTouchDownRepeat];
		[self addSubview:_gameAction];
		[self updateGameAction];
		
		// progress colors
		self.progress1Color = [brand globalColor:@"score-progress1" 
								 withDefaultValue:[UIColor colorWithRed:0.3 green:1.0 blue:0.3 alpha:0.4]];
		self.progress2Color = [brand globalColor:@"score-progress2" 
								withDefaultValue:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.4]];
		self.progress3Color = [brand globalColor:@"score-progress3" 
								withDefaultValue:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.4]];
		
		// progress views
		self.progress1Image = [brand globalImage:@"score-progress-1" withDefaultValue:NULL];
		self.progress2Image = [brand globalImage:@"score-progress-2" withDefaultValue:NULL];
		self.progress3Image = [brand globalImage:@"score-progress-3" withDefaultValue:NULL];
	}
    return self;
}

-(void)dealloc
{
	[_scoreNumberFormatter release];
	[_score release];
	[_message release];
	[_message1 release];
	[_message2 release];
	[_playState release];
	[_gameAction release];
	[_playImage release];
	[_pauseImage release];
	[_hintImage release];
	[_progress1Color release];
	[_progress2Color release];
	[_progress3Color release];
	[_walletView release];
	[_limitationsLabel release];
	[_wordCountLabel release];
	[_progress1Image release];
	[_progress2Image release];
	[_progress3Image release];
	
	[super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
	if ( !_model )
		return;
	
	Brand*			brand = [BrandManager currentBrand];
	CGContextRef	context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColorWithColor(context, [brand globalGridColor].CGColor);
	CGContextSetFillColorWithColor(context, [brand globalBackgroundColor].CGColor);
	CGContextSetLineWidth(context, [brand globalGridLineWidth]);
	
	// frame
	CGRect			frameRect = {{0.5,0.5}, {[self frame].size.width-1, [self frame].size.height-1} };
	//CGContextClearRect(context, frameRect);	
	CGContextFillRect(context, frameRect);	
	CGContextAddRect(context, frameRect);
	CGContextStrokePath(context);
	
	// progress
	CGRect			progressRect = {{AW(4),AW(4)}, {[_model progress] * ([self frame].size.width - AW(8)), ([self frame].size.height - AW(8)) / 2}};
	if ( !_progress1Image )
	{
		CGContextSetFillColorWithColor(context, _progress1Color.CGColor);
		CGContextFillRect(context, progressRect);
	}
	else
	{
		CGContextSaveGState(context);
		CGContextClipToRect(context, progressRect);
		[_progress1Image drawAtPoint:progressRect.origin];
		CGContextRestoreGState(context);
	}

	if ( [_model progress3] <= 0 )
	{
		progressRect.origin.y += progressRect.size.height;
		progressRect.size.width = [_model progress2] * ([self frame].size.width - AW(8));
		if ( !_progress2Image )
		{
			CGContextSetFillColorWithColor(context, _progress2Color.CGColor);
			CGContextFillRect(context, progressRect);
		}
		else
		{
			CGContextSaveGState(context);
			CGContextClipToRect(context, progressRect);
			[_progress2Image drawAtPoint:progressRect.origin];
			CGContextRestoreGState(context);
		}
	}
	else
	{
		progressRect.origin.y += progressRect.size.height;
		progressRect.size.width = [_model progress3] * ([self frame].size.width - AW(8));
		if ( !_progress3Image )
		{
			CGContextSetFillColorWithColor(context, _progress3Color.CGColor);
			CGContextFillRect(context, progressRect);	
		}
		else
		{
			CGContextSaveGState(context);
			CGContextClipToRect(context, progressRect);
			[_progress3Image drawAtPoint:progressRect.origin];
			CGContextRestoreGState(context);
		}
	}
}

-(void)updateScore
{
	//score.text = [NSString stringWithFormat:@"%d", [_model score]];
	
	if ( [_model scoreDisplayOffset] != -1 )
	{
		NSNumber*		number = [NSNumber numberWithInt:([_model score] + [_model scoreDisplayOffset])];
		_score.text = [number intValue] ? [_scoreNumberFormatter stringFromNumber:number] : @"";
		_score.alpha = 1.0;
		_message.alpha = 0.0;
		_message1.alpha = 0.0;
		_message2.alpha = 0.0;
		
		if ( [number intValue] < 0 )
		{
			NSLog(@"***** negative score about to be displayed ... (%d) - blocked", [number intValue]);
			_score.alpha = 0.0;
		}
	}
	
	// for now ..
	[self updateWallet];
}

-(void)updateWallet
{
	// don't update if version (of contents) has not changed
	Wallet*		wallet = [_model wallet];
	int			version = [wallet version];
	
	if ( version == walletVersion )
		return;
	walletVersion = version;
	
	// clear view
	for ( UIView* sub in [_walletView subviews] )
		[sub removeFromSuperview];
	
	// walk on wallet's content, fill from right to left
	int			x = _walletView.frame.size.width;
	for ( NSString* itemName in [wallet allWalletItems] )
	{
		int				step = [wallet walletItemDisplayStepSize:itemName];
		int				value = [wallet walletItemValue:itemName] / step;
		
		for ( int count = 0 ; value > 0 && count < 5 ; value -= step, count++ )
		{
			UIImage*		image = [[[[[[NSBundle mainBundle] classNamed:itemName] alloc] init] autorelease]
								 performSelector:@selector(buildImage)];
			if ( !image )
				continue;
			CGRect			imageFrame = CGRectMake(x - WALLET_ITEM_WIDTH, 0, WALLET_ITEM_WIDTH, WALLET_ITEM_HEIGHT);
			if ( imageFrame.origin.x < 0 )
				break;
			x -= (imageFrame.size.width + WALLET_ITEM_PADDING);
			UIImageView*	imageView = [[[UIImageView alloc] initWithFrame:imageFrame] autorelease];
			imageView.image = image;
			[_walletView addSubview:imageView];
		}
	}
}

-(void)updateProgress
{
	[self setNeedsDisplay];
}

-(void)updateMessage
{
	_message.text = RTL([_model message]);
	_score.alpha = 0.0;
	_message.alpha = 1.0;
	_message1.alpha = 0.0;
	_message2.alpha = 0.0;
}

-(void)updateMessage12
{
	_message1.text = RTL([_model message1]);
	_message2.text = RTL([_model message2]);
	_score.alpha = 0.0;
	_message.alpha = 0.0;
	_message1.alpha = 1.0;
	_message2.alpha = 1.0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[_model onTouched:1];
}

-(void)updatePlayState
{
	if ( !_model.allowPlayPause && !CHEAT_ON(CHEAT_PLAY_PAUSE_AT_WILL) )
		return;
	
	switch ( [_model playState] )
	{
		case PS_NONE :
			_playState.alpha = 0;
			break;
			
		case PS_PLAYING :
			_playState.alpha = 1.0;
			//[_playState setTitle:@"S" forState:UIControlStateNormal];
			[_playState setImage:_pauseImage forState:UIControlStateNormal];
			[self animateSelection:_playState];
			break;
			
		case PS_PAUSED :
			_playState.alpha = 1.0;
			//[_playState setTitle:@"P" forState:UIControlStateNormal];
			[_playState setImage:_playImage forState:UIControlStateNormal];
			[self animateSelection:_playState];
			break;
	}
}

-(void)updateGameAction
{	
	switch ( [_model gameAction] )
	{
		case GA_NONE :
			_gameAction.alpha = 0;
			break;
			
		case GA_HINT :
			if ( !_model.allowShowHint && !CHEAT_ON(CHEAT_SHOW_HINTS_AT_WILL) )
				_gameAction.alpha = 0;
			else
			{
				_gameAction.alpha = 1;
				//[_gameAction setTitle:@"H" forState:UIControlStateNormal];
				[_gameAction setImage:_hintImage forState:UIControlStateNormal];
				[self animateSelection:_gameAction];

			}
			break;
	}
}

-(void)playStateTouched
{
	[self animateSelection:_playState];
	[[[_model eventsTarget] soundTheme] pieceSelected];
	//NSLog(@"playStateTouched");
	[_model onTouched:3];
}

-(void)gameActionTouched
{
	NSLog(@"gameActionTouched");
	[self animateSelection:_gameAction];
	[[[_model eventsTarget] soundTheme] pieceSelected];
	[_model onTouched:2];
}

-(void)gameActionTouched2
{
	NSLog(@"gameActionTouched2");
	[self animateSelection:_gameAction];
	[[[_model eventsTarget] soundTheme] pieceSelected];
	[_model onTouched:22];
}


+(UIImage*)buildPauseImage
{
	UIImage*	image = [[BrandManager currentBrand] globalImage:@"button-pause" withDefaultValue:NULL];
	if ( image )
		return image;
	
	if ( ![globalData objectForKey:PAUSEIMAGE_KEY] )
	{	
		UIColor*		color = [[BrandManager currentBrand] globalTextColor];
		
		UIGraphicsBeginImageContext(CGSizeMake(AW(24.0f), AW(24.0f)));
		CGContextRef context = UIGraphicsGetCurrentContext();		
		UIGraphicsPushContext(context);								

		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextSetLineWidth(context, 1.0);

		CGContextFillRect(context, CGRectMake(AW(4), AW(4), AW(7), AW(18)));
		CGContextFillRect(context, CGRectMake(AW(14), AW(4), AW(7), AW(18)));
		CGContextStrokePath(context);

		UIGraphicsPopContext();								
		[globalData setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:PAUSEIMAGE_KEY];
		UIGraphicsEndImageContext();
	}
	
	return [globalData objectForKey:PAUSEIMAGE_KEY];
}

+(UIImage*)buildPlayImage
{
	UIImage*	image = [[BrandManager currentBrand] globalImage:@"button-play" withDefaultValue:NULL];
	if ( image )
		return image;
	
	if ( ![globalData objectForKey:PLAYIMAGE_KEY] )
	{
		UIColor*		color = [[BrandManager currentBrand] globalTextColor];
		
		UIGraphicsBeginImageContext(CGSizeMake(AW(24.0f), AW(24.0f)));
		CGContextRef context = UIGraphicsGetCurrentContext();		
		UIGraphicsPushContext(context);								
		
		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextSetLineWidth(context, 1.0);
		
		CGPoint			points[] = {AW(4), AW(4), AW(21), AW(13), AW(4), AW(22)};
		CGContextAddLines(context, points, sizeof(points) / sizeof(points[0]));
		CGContextFillPath(context);
		
		UIGraphicsPopContext();								
		[globalData setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:PLAYIMAGE_KEY];
		UIGraphicsEndImageContext();
	}
	
	return [globalData objectForKey:PLAYIMAGE_KEY];	
}

+(UIImage*)buildHintImage
{
	UIImage*	image = [[BrandManager currentBrand] globalImage:@"button-hint" withDefaultValue:NULL];
	if ( image )
		return image;
	
	if ( ![globalData objectForKey:HINTIMAGE_KEY] )
	{
		UIColor*		color = [[BrandManager currentBrand] globalTextColor];
		
		UIGraphicsBeginImageContext(CGSizeMake(AW(24.0f), AW(24.0f)));
		CGContextRef context = UIGraphicsGetCurrentContext();		
		UIGraphicsPushContext(context);								
		
		CGContextSetStrokeColorWithColor(context, color.CGColor);
		CGContextSetFillColorWithColor(context, color.CGColor);
		CGContextSetLineWidth(context, 1.0);
		
		int				pointCount = 10;
		CGPoint			*points = alloca(sizeof(CGPoint) * pointCount);
		double			angle = 0;
		double			angleDelta = M_PI * 2 / pointCount;
		double			radiusEven = AW(12);
		double			radiusOdd = AW(6);
		double			centerX = AW(12);
		double			centerY = AW(12);
		for ( int pointIndex = 0 ; pointIndex < pointCount ; pointIndex++ )
		{
			double	radius = (pointIndex % 2) ? radiusOdd : radiusEven;
			double	x = sin(angle) * radius;
			double	y = cos(angle) * radius;
			
			points[pointIndex].x = centerX + x;
			points[pointIndex].y = centerY + y;
			
			angle += angleDelta;
		}
		CGContextAddLines(context, points, pointCount);
		CGContextFillPath(context);
		
		UIGraphicsPopContext();								
		[globalData setObject:UIGraphicsGetImageFromCurrentImageContext() forKey:HINTIMAGE_KEY];
		UIGraphicsEndImageContext();
	}
	
	return [globalData objectForKey:HINTIMAGE_KEY];	
}

-(void)animateSelection:(UIView*)view
{
	[UIView beginAnimations:nil context:view];
	[UIView setAnimationDuration:0.2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animateSelectionDidStop:finished:context:)];
	view.transform = CGAffineTransformMakeScale(1.6, 1.6);
	[UIView commitAnimations];				
}

-(void)animateSelectionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	UIView*		view = context;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	view.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];					
}

@end
