//
//  AuctionSymbolDispenser.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RandomSymbolDispenser.h"
#import "Board.h"
#import "AuctionManager.h"
#import "AuctionRoom.h"

@interface AuctionSymbolDispenser : RandomSymbolDispenser {

	id<Board>			_board;
	
	id<AuctionRoom>		_room;
	id<AuctionArticle>	_article;
}
@property (retain) id<Board> board;
@property (retain) id<AuctionRoom> room;
@property (retain) id<AuctionArticle> article;

-(id)initWithBoard:(id<Board>)board;

@end
