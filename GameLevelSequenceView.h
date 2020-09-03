//
//  GameLevelSequenceView.h
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameLevelSequence;

@interface GameLevelSequenceView : UIView {

	GameLevelSequence*		_model;
}
@property (nonatomic,assign) GameLevelSequence* model;

- (id)initWithFrame:(CGRect)frame andModel:(GameLevelSequence*)initModel;

@end
