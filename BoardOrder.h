/*
 *  BoardOrder.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/23/09.
 *  Copyright 2009 Dror Kessler (M). All rights reserved.
 *
 */

@protocol BoardOrder<NSObject>

//-(int)cellIndexOf:(CGPoint)coor;
//-(CGPoint)coorOf:(int)cellIndex;

-(int)indexOfOrder:(int)order;
-(int)orderOfIndex:(int)index;

@end


