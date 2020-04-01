//
//  AuctionRoom.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionParticipant.h"

@protocol AuctionManager;

@protocol AuctionRoom<NSObject>

-(NSSet*)allParticipants;
-(int)size;
-(void)removeAll;
-(void)addParticipant:(id<AuctionParticipant>)participant;
-(void)removeParticipant:(id<AuctionParticipant>)participant;

-(void)prepareForBids;

@property (retain) id<AuctionManager> manager;
@property int capacity;


@end
