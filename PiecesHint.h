/*
 *  PiecesHint.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/16/09.
 *  Copyright 2009 Dror Kessler (M). All rights reserved.
 *
 */

#import "Piece.h"

@protocol PiecesHint <NSObject>

-(int)size;
-(id<Piece>)pieceAt:(int)index;
-(id<Piece>)replacePieceAt:(int)index withPiece:(id<Piece>)newPiece;
-(NSArray*)allPieces;

@end

