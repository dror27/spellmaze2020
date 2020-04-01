/*
 *  ScoreWidgetEventsTarget.h
 *  Board3
 *
 *  Created by Dror Kessler on 7/25/09.
 *  Copyright 2009 Dror Kessler (M). All rights reserved.
 *
 */

@class SoundTheme;
@protocol ScoreWidgetEventsTarget <NSObject>
-(void)onScoreWidgetTouched:(int)tapCount;
-(SoundTheme*)soundTheme;
@end

