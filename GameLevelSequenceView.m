//
//  GameLevelSequenceView.m
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GameLevelSequenceView.h"

@implementation GameLevelSequenceView
@synthesize model = _model;

-(id)initWithFrame:(CGRect)frame andModel:(GameLevelSequence*)initModel 
{
    if (self = [super initWithFrame:frame]) 
	{
		self.model = initModel;
		
		self.backgroundColor = [UIColor clearColor];
    }
	
    return self;
}
@end
