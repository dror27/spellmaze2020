//
//  PieceDecorator.h
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import "PieceDecorator.h"
#import "Piece.h"

@protocol PieceDecorator<NSObject>
-(void)decorate:(id<Piece>)piece;
-(void)undecorate;
@end
