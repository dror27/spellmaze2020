//
//  AuctionRoomImpl.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AuctionRoomImpl.h"

//#define	DUMP

@implementation AuctionRoomImpl
@synthesize participants = _participants;
@synthesize manager = _manager;
@synthesize usher = _usher;
@synthesize capacity;

-(id)init
{
	if ( self = [super init] )
	{
		self.participants = [NSMutableSet set];
		self.capacity = AUCTION_ROOT_IMPL_INITIAL_CAPACITY;
	}
	return self;
}

-(void)dealloc
{
	[_participants release];
	[_manager release];
	[_usher release];
	
	[super dealloc];
}

-(NSSet*)allParticipants
{
	return _participants;
}

-(int)size
{
	return [_participants count];
}

-(void)removeAll
{
	[_participants removeAllObjects];
}

-(void)addParticipant:(id<AuctionParticipant>)participant
{
	[_participants addObject:participant];
}

-(void)removeParticipant:(id<AuctionParticipant>)participant
{
	[_participants removeObject:participant];
}

-(void)prepareForBids
{
	[_usher prepareRoomForBids:self];
	
	// take all participants done bidding out
	NSMutableArray*		queue = [NSMutableArray array];
	for ( id<AuctionParticipant> participant in _participants )
		if ( [participant doneBidding] )
		{
#ifdef DUMP
			NSLog(@"[AuctionRoomImpl] doneBidding: %@", participant);
#endif
			[queue addObject:participant];
		}
	
	for ( id<AuctionParticipant> participant in queue )
		[_participants removeObject:participant];
}


@end
