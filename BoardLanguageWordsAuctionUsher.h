//
//  BoardLanguageWordsAuctionUsher.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionUsher.h"
#import "AuctionRoom.h"
#import "Board.h"
#import "CSetWrapper.h"
#import "WordQueue.h"

@protocol Language;
@interface BoardLanguageWordsAuctionUsher : NSObject<AuctionUsher> {

	id<Board>			_board;
	id<Language>		_language;
	int					minWordSize;
	
	WordQueue*			_wordQueue;
	int					nextWordQueueWordSize;

	BOOL				didInitialize;
}
-(id)initWithBoard:(id<Board>)board;

@property (nonatomic,assign,readonly) id<Board> board;
@property (nonatomic,assign,readonly) id<Language> language;
@property (retain) WordQueue* wordQueue;

@end
