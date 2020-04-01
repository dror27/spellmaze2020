//
//  AuctionBid.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AuctionManager, AuctionRoom, AuctionArticle;
@protocol AuctionBid<NSObject>

-(double)price;
-(NSObject*)key;

-(void)didWinAuction:(id<AuctionArticle>)article inRoom:(id<AuctionRoom>)room;
@end
