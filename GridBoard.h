//
//  GridBoard.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"
#import "Piece.h"
#import	"HasView.h"
#import "Board.h"

@class GridBoardView;
@class GameLevel;

@interface GridBoard : NSObject<Board> {
	
	int				width;
	int				height;
	Cell**			_cells;
	
	GameLevel*		_level;
	
	GridBoardView*	_view;
	
	BOOL			piecesSelectable;
	
	UIColor*		_gridColor;
	
	CGRect			suggestedFrame;
}
@property (readonly) int width;
@property (readonly) int height;
@property (retain) GridBoardView* view;
@property (nonatomic,assign) GameLevel* level;
@property BOOL piecesSelectable;
@property (retain) UIColor* gridColor;
@property CGRect suggestedFrame;

-(id)initWithWidth:(int)initWidth andHeight:(int)initHeight;

-(Cell*)cellAt:(int)x andY:(int)y;
-(id<Piece>)pieceAt:(int)x andY:(int)y;
-(id<Piece>)placePiece:(id<Piece>)piece at:(int)x andY:(int)y;
-(CGPoint)randomFreeCellCoor;



@end
