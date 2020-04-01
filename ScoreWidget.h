//
//  ScoreWidget.h
//  Board3
//
//  Created by Dror Kessler on 6/2/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasView.h"
#import "ScoreWidgetView.h"
#import "ScoreWidgetEventsTarget.h"
#import "Wallet.h"

typedef enum
{
	PS_NONE = 0,
	PS_PLAYING,
	PS_PAUSED
} ScoreWidget_PlayState;

typedef enum
{
	GA_NONE = 0,
	GA_HINT,
} ScoreWidget_GameAction;

@interface ScoreWidget : NSObject<HasView> {

	int						score;
	float					progress;
	float					progress2;
	float					progress3;
	
	NSString*				_message;
	NSString*				_message1;
	NSString*				_message2;
	
	ScoreWidget_PlayState	playState;
	ScoreWidget_GameAction	gameAction;
	
	ScoreWidgetView*		_view;
	id<ScoreWidgetEventsTarget> _eventsTarget;
	
	BOOL					allowPlayPause;
	BOOL					allowShowHint;
	
	int						scoreDisplayOffset;
}

@property (retain) ScoreWidgetView* view;
@property (readonly) int score;
@property float progress;
@property float progress2;
@property float progress3;
@property (retain) NSString* message;
@property (retain) NSString* message1;
@property (retain) NSString* message2;
@property (nonatomic,assign) id<ScoreWidgetEventsTarget> eventsTarget;
@property ScoreWidget_PlayState playState;
@property ScoreWidget_GameAction gameAction;
@property BOOL allowPlayPause;
@property BOOL allowShowHint;
@property (readonly) Wallet* wallet;
@property int scoreDisplayOffset;

-(void)resetAll;
-(void)addToScore:(int)inc;
-(void)commitScore;
-(void)updateWallet;
-(void)onTouched:(int)tapCount;

-(void)pressPlayAction;

@end
