//
//  SymbolAuctionBid.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionBid.h"
#import "AuctionManager.h"
#import "AuctionParticipant.h"

@interface SymbolAuctionBid : NSObject<AuctionBid> {

	unichar					symbol;
	NSObject*				_key;
	double					price;
	id<AuctionParticipant>	_participant;
}
@property double price;
@property (retain) id<AuctionParticipant> participant;

-(id)initWithSymbol:(unichar)symbol;

-(unichar)symbol;

@end
