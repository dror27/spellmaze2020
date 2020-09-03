//
//  CompoundGameBoardLogic.h
//  Board3
//
//  Created by Dror Kessler on 5/25/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardLogicBase.h"


@interface CompoundGameBoardLogic : GameBoardLogicBase {

	NSMutableArray*	_logics;
	
}
@property (retain) NSMutableArray* logics;

-(void)add:(id<GameBoardLogic>)logic;
-(int)count;
@end
