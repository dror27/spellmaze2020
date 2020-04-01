//
//  PieceDispenser.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import "PieceDispensingTarget.h"
#import "HasView.h"

@protocol PieceDispenser<NSObject,HasView>

-(void)startDispensing:(id<PieceDispensingTarget>)target andContext:(void*)context;
-(void)stopDispensing;
-(void)resumeDispensing;

-(float)progress;
-(int)piecesLeft;

-(void)setTarget:(id<PieceDispensingTarget>)target;
@end
