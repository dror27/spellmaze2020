//
//  ScoreWidgetView.h
//  Board3
//
//  Created by Dror Kessler on 6/2/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScoreWidget;
@class GridBoard;
@interface ScoreWidgetView : UIView {

	ScoreWidget*		_model;
	
	NSNumberFormatter*	_scoreNumberFormatter;
	
	UILabel*			_score;
	UILabel*			_message;

	UILabel*			_message1;
	UILabel*			_message2;
	
	UIButton*			_playState;
	UIButton*			_gameAction;
	
	UIImage*			_playImage;
	UIImage*			_pauseImage;
	UIImage*			_hintImage;
	
	UIColor*			_progress1Color;
	UIColor*			_progress2Color;
	UIColor*			_progress3Color;
	
	UIView*				_walletView;
	int					walletVersion;
	
	UILabel*			_limitationsLabel;
	UILabel*			_wordCountLabel;
	
	UIImage*			_progress1Image;
	UIImage*			_progress2Image;
	UIImage*			_progress3Image;
}
@property (nonatomic,assign) ScoreWidget* model;
@property (retain) NSNumberFormatter* scoreNumberFormatter;
@property (retain) UILabel* score;
@property (retain) UILabel* message;
@property (retain) UILabel* message1;
@property (retain) UILabel* message2;
@property (retain) UIButton* playState;
@property (retain) UIButton* gameAction;
@property (retain) UIImage* playImage;
@property (retain) UIImage* pauseImage;
@property (retain) UIImage* hintImage;
@property (retain) UIColor* progress1Color;
@property (retain) UIColor* progress2Color;
@property (retain) UIColor* progress3Color;
@property (retain) UIView* walletView;
@property (retain) UILabel* limitationsLabel;
@property (retain) UILabel* wordCountLabel;
@property (retain) UIImage* progress1Image;
@property (retain) UIImage* progress2Image;
@property (retain) UIImage* progress3Image;


-(id)initWithFrame:(CGRect)frame andModel:(ScoreWidget*)initModel;
-(void)updateScore;
-(void)updateProgress;
-(void)updateMessage;
-(void)updateMessage12;
-(void)updatePlayState;
-(void)updateGameAction;
-(void)updateWallet;
-(void)playStateTouched;
-(void)gameActionTouched;
@end
