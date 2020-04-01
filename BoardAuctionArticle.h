//
//  BoardAuctionArticle.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionArticle.h"
#import "Board.h"


@interface BoardAuctionArticle : NSObject<AuctionArticle> {

	id<Board>		_board;
	
	unichar*		_symbols;
	int				symbolCount;
	
	unichar			leadingSymbol;
	id<Piece>		_leadingPiece;
}

-(id)initWithBoard:(id<Board>)board;
-(unichar*)symbols;
-(int)symbolCount;
-(id<Board>)board;
-(unichar)leadingSymbol;

@property (retain) id<Piece> leadingPiece;

@end
