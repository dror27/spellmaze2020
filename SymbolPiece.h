//
//  SymbolPiece.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"
#import "Piece.h"
#import "Board.h"
#import "PieceEventsTarget.h"

#define	ADVANCED_SCALING

@class SymbolPieceView;

@interface SymbolPiece : NSObject<Piece> {

	NSString*	_text;
	UIImage*	_image;
	
	Cell*		_d_cell;
	BOOL		isSelected;
	
	SymbolPieceView* _view;
	CGSize		viewSize;
	
	NSMutableDictionary* _props;	
	
	id<PieceEventsTarget>	_d_eventsTarget;
	
	NSMutableDictionary*	_decorators;
	
	BOOL		showSymbolText;
}
@property unichar symbol;
@property (retain) NSString* text;
@property (retain) UIImage* image;
@property (retain) SymbolPieceView* view;
@property (retain) NSMutableDictionary* props;
@property (retain) NSMutableDictionary* decorators;
@property BOOL isSelected;
@property BOOL showSymbolText;

#define	SYMBOL_PIECE_POS_COLOR_HINT		@"SYMBOL_PIECE_POS_COLOR_HINT"


@end
