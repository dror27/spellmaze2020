/*
 *  PieceEventsTarget.h
 *  Board3
 *
 *  Created by Dror Kessler on 6/15/09.
 *  Copyright 2020 Dror Kessler (M). All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol Piece;
@protocol PieceEventsTarget<NSObject>
-(void)pieceSelected:(id<Piece>)piece;
-(void)pieceReselected:(id<Piece>)piece;
-(void)pieceClicked:(id<Piece>)piece;

@optional
-(void)disabledPieceClicked:(id<Piece>)piece;
@end
