//
//  ConstantBoardPotentialFunction.h
//  Board3
//
//  Created by Dror Kessler on 7/16/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardPotentialFunction.h"

@interface ConstantBoardPotentialFunction : NSObject<BoardPotentialFunction> {

	float	thePotential;
}
@property float thePotential;

@end
