//
//  GridBoardPieceDispenserBase.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PieceDispenser.h"
#import "HasView.h"
#import "GridBoard.h"
#import "GridBoardView.h"
#import "SymbolDispenser.h"
#import "GridBoardPieceDispenserView.h"
#import "GameLevel.h"
#import "SymbolPiece.h"

@interface GridBoardPieceDispenserBase : NSObject<HasView,PieceDispenser> {

	GridBoard*				_ownBoard;
	
	NSTimer*				_dispensingTickTimer;
	float					dispensingTickPeriod;
	float					boardFullnessTickPeriodFactor;		// (-1.0 -> 1.0) 0.0 - neutral, 0.0-1.0 - faster when the board is emptier, -1.0-0.0 - slower when the board is emptier
	float					boardFullnessTickPeriodCurve;		// (-1.0 -> 1.0) 0.0 - normal, -1 - weakest, 1 stronest
	float					boardProgressTickPeriodFactor;		// (-1.0 -> 1.0) 0.0 - neutral, 0.0-1.0 faster as progress advances, -1.0-0.0 slow as progres advances
	float					dispenserProgressTickPeriodFactor;	// (-1.0 -> 1.0) 0.0 - neutral, 0.0-1.0 faster as progress advances, -1.0-0.0 slow as progres advances
	
	
	float					gameSpeed;
	
	GridBoardPieceDispenserView* _view;
	id<PieceDispensingTarget> _target;
	void*					_context;
	
	BOOL					dispensing;

}
@property (retain) GridBoard* ownBoard;
@property (retain) NSTimer* dispensingTickTimer;

@property float dispensingTickPeriod;
@property float boardFullnessTickPeriodFactor;
@property float boardFullnessTickPeriodCurve;
@property float boardProgressTickPeriodFactor;
@property float dispenserProgressTickPeriodFactor;

@property (retain) GridBoardPieceDispenserView* view;
@property (nonatomic,assign) id<PieceDispensingTarget> target;


-(float)nextTickPeriod;

-(SymbolPiece*)piece:(unichar)symbol withImage:(UIImage*)image;

@end
