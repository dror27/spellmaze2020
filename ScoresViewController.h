//
//  ScoresViewController.h
//  Board3
//
//  Created by Dror Kessler on 7/14/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ScoreWidgetEventsTarget.h"

@class ScoreTableWidget;
@class ScoresComm;
@class SoundTheme;
@interface ScoresViewController : UIViewController<ScoreWidgetEventsTarget> {

	ScoreTableWidget*		_scoreTable;
	ScoresComm*				_scoresComm;
	SoundTheme*				_soundTheme;
	BOOL					zombie;
	
}
@property (retain) ScoreTableWidget* scoreTable;
@property (retain) ScoresComm* scoresComm;
@property (retain) SoundTheme* soundTheme;

+(void)executePullRequests:(NSDictionary*)score;
+(BOOL)executePullRequestsWorthLaunching:(NSDictionary*)scores;
@end
