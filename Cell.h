//
//  Cell.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Piece.h"
#import "HasView.h"
#import "Board.h"
#import "GridCell.h"

@class CellView;

@interface Cell : NSObject<HasView,GridCell> {

	id<Piece>	_piece;
	
	id<Board>	_board;
	CellView*	_view;
	
	int			x;
	int			y;
	
}
@property (retain) id<Piece> piece;
@property (retain) CellView* view;
@property (nonatomic,assign) id<Board> board;
@property int x;
@property int y;
@property BOOL highlight;
-(void)abandonPiece;

@end
