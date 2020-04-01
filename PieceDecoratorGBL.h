//
//  PieceDecoratorGBL.h
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"GameBoardLogicBase.h"

@interface PieceDecoratorGBL : GameBoardLogicBase {
	
	NSDictionary*			_decorations;
	float					_probSum;
}

@property (retain) NSDictionary* decorations;

-(void)setDecoration:(NSString*)decoration withProb:(float)prob;

@end
