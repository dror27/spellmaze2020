/*
 *  PieceView.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/27/09.
 *  Copyright 2009 Dror Kessler (M). All rights reserved.
 *
 */

@protocol PieceView

-(void)placed;
-(void)hinted:(BOOL)last;
-(void)eliminate;
-(void)examine;
-(void)click;
@end

