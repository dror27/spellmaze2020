//
//  AuctionManager.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionArticle.h"
#import "AuctionBid.h"
#import "AuctionRoom.h"

@protocol AuctionManager<NSObject>

-(id<AuctionBid>)sell:(id<AuctionArticle>)article inRoom:(id<AuctionRoom>)room;

@end

