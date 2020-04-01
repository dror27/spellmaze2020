/*
 *  AuctionUsher.h
 *  SpellMaze
 *
 *  Created by Dror Kessler on 11/24/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@protocol AuctionRoom;
@protocol AuctionUsher<NSObject>

-(void)prepareRoomForBids:(id<AuctionRoom>)room;

@end


