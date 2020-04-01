//
//  GridBoardPieceDispenserSymbols.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridBoardPieceDispenserBase.h"
#import "SingleProbabilityURS.h"


@interface GridBoardPieceDispenserSymbols : GridBoardPieceDispenserBase {

	id<SymbolDispenser>		_symbolDispenser;
	float					rushDispensingFactor;
	BOOL					lastRushDispensing;
	
	float					jokerProb;
	SingleProbabilityURS*	_jokerURS;
}
@property (retain) id<SymbolDispenser> symbolDispenser;
@property float rushDispensingFactor;
@property float jokerProb;
@property (retain) SingleProbabilityURS* jokerURS;

@end
