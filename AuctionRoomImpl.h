//
//  AuctionRoomImpl.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionRoom.h"
#import "AuctionManager.h"
#import	"AuctionUsher.h"

#define	AUCTION_ROOT_IMPL_INITIAL_CAPACITY		200


@interface AuctionRoomImpl : NSObject<AuctionRoom> {

	NSMutableSet*		_participants;
	id<AuctionManager>	_manager;
	id<AuctionUsher>	_usher;
	
	int					capacity;
}
@property (retain) NSMutableSet* participants;
@property (retain) id<AuctionManager> manager;
@property (retain) id<AuctionUsher>	usher;
@property int capacity;


@end
