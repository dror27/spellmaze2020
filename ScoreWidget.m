//
//  ScoreWidget.m
//  Board3
//
//  Created by Dror Kessler on 6/2/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "ScoreWidget.h"
#import "UserPrefs.h"

static int		scoreFactor = 1;


@implementation ScoreWidget
@synthesize view = _view;
@synthesize eventsTarget = _eventsTarget;
@synthesize allowPlayPause;
@synthesize allowShowHint;
@synthesize scoreDisplayOffset;

-(id)init
{
	if ( self = [super init] )
	{
		score = [UserPrefs getInteger:PK_SCORE withDefault:0];
		scoreDisplayOffset = -1;		// will not display score until this is set...
	}
	return self;
}

-(void)dealloc
{
	[_message release];
	[_message1 release];
	[_message2 release];
	
	[_view setModel:nil];
	[_view release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( _view == NULL )
		self.view = [[[ScoreWidgetView alloc] initWithFrame:frame andModel:self] autorelease];
	
	return _view;
}

-(void)resetAll
{
	progress = 0;
	
	[_view updateScore];
	[_view updateProgress];
}

-(void)addToScore:(int)incr
{
	score = [UserPrefs getInteger:PK_SCORE withDefault:0];
	score += (incr * scoreFactor);
	[self commitScore];
	
	[_view updateScore];
}

-(void)commitScore
{
	[UserPrefs setInteger:PK_SCORE withValue:score];
}

-(int)score
{
	score = [UserPrefs getInteger:PK_SCORE withDefault:0];
	return score;
}

/*
-(void)setScore:(int)newScore
{
	score = newScore;
	
	[_view updateScore];
}
*/

-(float)progress
{
	return progress;
}

-(void)setProgress:(float)newProgress
{
	progress = newProgress;
	
	[_view updateProgress];
}

-(float)progress2
{
	return progress2;
}

-(void)setProgress2:(float)newProgress2
{
	progress2 = newProgress2;
	
	[_view updateProgress];
}

-(float)progress3
{
	return progress3;
}

-(void)setProgress3:(float)newProgress3
{
	progress3 = newProgress3;
	
	[_view updateProgress];
}

-(NSString*)message
{
	return _message;
}

-(void)setMessage:(NSString*)newMessage
{
	[_message autorelease];
	_message = [newMessage retain];
	
	[_view updateMessage];
}

-(NSString*)message1
{
	return _message1;
}

-(void)setMessage1:(NSString*)newMessage
{
	[_message1 autorelease];
	_message1 = [newMessage retain];
	
	[_view updateMessage12];
}

-(NSString*)message2
{
	return _message2;
}

-(void)setMessage2:(NSString*)newMessage
{
	[_message2 autorelease];
	_message2 = [newMessage retain];
	
	[_view updateMessage12];
}

-(ScoreWidget_PlayState)playState
{
	return playState;
}

-(void)setPlayState:(ScoreWidget_PlayState)newPlayState
{
	playState = newPlayState;
	
	[_view updatePlayState];
}

-(ScoreWidget_GameAction)gameAction
{
	return gameAction;
}

-(void)setGameAction:(ScoreWidget_GameAction)newGameAction
{
	gameAction = newGameAction;
	
	[_view updateGameAction];
}

-(void)onTouched:(int)tapCount
{
	[_view updateScore];
	if ( _eventsTarget )
		[_eventsTarget onScoreWidgetTouched:tapCount];

}

-(Wallet*)wallet
{
	return [Wallet singleton];
}

-(void)updateWallet
{
	[_view updateWallet];
}

-(void)pressPlayAction
{
	[_view playStateTouched];
}

@end
