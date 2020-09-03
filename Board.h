//
//  Board.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Piece.h"
#import "HasView.h"

@class GameLevel;
@class Cell;

@protocol Board <NSObject,HasView>

-(int)cellCount;
-(int)freeCellCount;
-(BOOL)isEmpty;

-(Cell*)cellAt:(int)index;
-(NSArray*)allCells;

-(id<Piece>)pieceAt:(int)index;
-(NSArray*)allPieces;
-(id<Piece>)placePiece:(id<Piece>)piece at:(int)index;

-(int)randomFreeCellIndex;

-(BOOL)piecesSelectable;
-(void)setPiecesSelectable:(BOOL)pieceSelectable;

-(CGRect)suggestedFrame;
-(void)setSuggestedFrame:(CGRect)suggestedFrame;

@property (nonatomic,assign) GameLevel* level;
@end
