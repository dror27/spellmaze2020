//
//  GridBoardPieceDispenserView.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoardPieceDispenserView.h"
#import "GridBoardPieceDispenserBase.h"


@implementation GridBoardPieceDispenserView
@synthesize model = _model;

-(id)initWithFrame:(CGRect)frame andModel:(GridBoardPieceDispenserBase*)initModel
{
	if (self = [super initWithFrame:frame]) 
	{
		self.model = initModel;
		
		UIView*	boardView = [[_model ownBoard] viewWithFrame:frame];
		
		[self addSubview:boardView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	//NSLog(@"GridBoardPieceDispenserView: touchesBegan");
	
}


- (void)dealloc {
    [super dealloc];
}


@end
