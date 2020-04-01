//
//  GameLevelView.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnvelopeDynamics.h"

@class GameLevel;
@class ScoreWidgetView;

//#define		GAMELEVELVIEW_MONITOR


typedef enum
{
	HintImagePositionCenter = 0,
	HintImagePositionCorner = 1
} HintImagePosition;

@interface GameLevelView : UIView {
	
	GameLevel*		_model;
	UILabel*		_monitor;
	UILabel*		_symbolsLeft;
	
	HintImagePosition	hintImagePosition;
	float				delayFactor;
	CGRect				hintImageFrame;
	float				polaroidMargin;
	float				polaroidMarginBottom;
	
	UIImageView*		_pauseCurtain;
	BOOL				pauseCurtainShown;
	
	BOOL				showSymbolsLeftCounter;
	
}
@property (nonatomic,assign) GameLevel* model;
#ifdef GAMELEVELVIEW_MONITOR
@property (retain) UILabel* monitor;
#endif
@property (retain) UILabel* symbolsLeft;
@property HintImagePosition hintImagePosition;
@property (retain) UIImageView*	pauseCurtain;

-(id)initWithFrame:(CGRect)frame andModel:(GameLevel*)initModel;
-(void)wordBlackListed:(NSString*)word;
-(void)showHintImage:(UIImage*)hintImage withEnvelope:(EnvelopeDynamics*)envelope;
-(void)updateMonitor:(NSString*)text;
-(void)updateSymbolsLeft:(NSString*)text;
	
-(void)tick;
-(void)fineTick;

-(void)updatePauseCurtain;

@end
