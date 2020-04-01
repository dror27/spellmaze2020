//
//  ScoreTableWidget.h
//  Board3
//
//  Created by Dror Kessler on 7/17/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasView.h"
#import "PieceEventsTarget.h"
#import "Board.h"
#import "WidgetBase.h"
#import "ScoreWidgetEventsTarget.h"
#import "Banner.h"

@class SoundTheme;
@class ScoreWidget;
@class GridBoard;

@interface ScoreTableWidget : WidgetBase<HasView,PieceEventsTarget> {

	UIView*			_view;

	GridBoard*		_boardA;
	GridBoard*		_boardB;
	ScoreWidget*	_panel;
	
	SoundTheme*		_soundTheme;	
	
	NSNumberFormatter*	_scoreNumberFormatter;	
	
	Banner*			_banner;
	
}
@property (retain) UIView* view;
@property (retain) GridBoard* boardA;
@property (retain) GridBoard* boardB;
@property (retain) ScoreWidget* panel;
@property (retain) SoundTheme* soundTheme;
@property (retain) NSNumberFormatter* scoreNumberFormatter;
@property (retain) Banner* banner;


-(void)reset;
-(void)appeared;
-(void)disappeared;
-(void)paintScores:(NSDictionary*)scores;

-(void)setPanelEventsTarget:(id<ScoreWidgetEventsTarget>)eventsTarget;



@end
