//
//  AuctionManagerImpl.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "AuctionManagerImpl.h"
#import "AuctionRoom.h"
#import "AuctionBid.h"
#import "NSArray_Random.h"

//#define	DUMP_TOP_BID
//#define	DUMP

@interface AuctionManagerImpl_BidBin : NSObject
{
	@public
	double				aggregatedPrice;
	int					aggregatedCount;
	NSMutableArray*		_bids;
}
@property (retain) NSMutableArray* bids;
@end

@implementation AuctionManagerImpl_BidBin
@synthesize bids = _bids;
-(id)init
{
	if ( self = [super init] )
	{
		aggregatedPrice = 0;
		aggregatedCount = 0;
		self.bids = [NSMutableArray array];
	}
	return self;
}

-(void)dealloc
{
	[_bids release];
	
	[super dealloc];
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<AuctionManagerImpl_BidBin: 0x%p, %f, %d, %@>", self, aggregatedPrice, aggregatedCount, _bids];
}

@end


@implementation AuctionManagerImpl

-(id)init
{
	if ( self = [super init] )
	{
		aggregationType = AuctionManagerImplAggregationTypeVertical;
	}
	return self;
}

-(id<AuctionBid>)sell:(id<AuctionArticle>)article inRoom:(id<AuctionRoom>)room
{
#ifdef DUMP
	NSLog(@"[AuctionManagerImpl] sell: %@ in %@", article, room);
#endif
	
	// prepare article for bids
	[article prepareForBids];
	[room prepareForBids];
	
	// collect bids from all participants
	NSMutableArray*		bids = [NSMutableArray array];
	double				priceThreshold = -1.0;
	BOOL				usePriceThreshold = (aggregationType == AuctionManagerImplAggregationTypeVertical);
	for ( id<AuctionParticipant> participant in [room allParticipants] )
	{
		NSArray*	participantBids = [participant bid:article withPriceThreshold:(usePriceThreshold ? &priceThreshold : NULL)];
		if ( participantBids )
			[bids addObjectsFromArray:participantBids];
	}
#ifdef DUMP
	NSLog(@"[AuctionManagerImpl] bids: %@", bids);
#endif	
	
	// initialize bins
	NSMutableDictionary*	bins = [NSMutableDictionary dictionary];
	for ( id<AuctionBid> bid in bids )
	{
		NSObject*						key = [bid key];
		AuctionManagerImpl_BidBin*		bin = [bins objectForKey:key];
		if ( !bin )
			[bins setObject:(bin = [[[AuctionManagerImpl_BidBin alloc] init] autorelease]) forKey:key];
		
		[bin.bids addObject:bid];
		
		// aggregate
		switch (aggregationType) 
		{
			case AuctionManagerImplAggregationTypeHorizontal :
			{
				bin->aggregatedPrice += [bid price];
				bin->aggregatedCount++;
				break;
			}
				
			case AuctionManagerImplAggregationTypeVertical :
			{
				double	price = [bid price];

				if ( price > bin->aggregatedPrice )
				{
					bin->aggregatedPrice = price;
					bin->aggregatedCount = 1;
				}
				else if ( price == bin->aggregatedPrice )
					bin->aggregatedCount++;
				break;
			}
		}
	}
#ifdef DUMP
	NSLog(@"[AuctionManagerImpl] bids: %@", bids);
#endif
	
	// pick top bins
	double				topBinsAggregatedPrice = -1.0;
	int					topBinsAggregatedCount = 0;
	NSMutableArray*		topBins = [NSMutableArray array];
	for ( AuctionManagerImpl_BidBin* bin in [bins allValues] )
		if ( (bin->aggregatedPrice > topBinsAggregatedPrice) || 
				((bin->aggregatedPrice == topBinsAggregatedPrice) && (bin->aggregatedCount > topBinsAggregatedCount)) )
		{
			topBinsAggregatedPrice = bin->aggregatedPrice;
			topBinsAggregatedCount = bin->aggregatedCount;
			[topBins removeAllObjects];
			[topBins addObject:bin];
		}
		else if ( bin->aggregatedPrice == topBinsAggregatedPrice && bin->aggregatedCount == topBinsAggregatedCount )
			[topBins addObject:bin];
	if ( ![topBins count] )
		return NULL;
	
	// select a bin
	AuctionManagerImpl_BidBin*	topBin = (AuctionManagerImpl_BidBin*)[topBins objectAtRandomIndex];
#ifdef DUMP
	NSLog(@"[AuctionManagerImpl] topBin: %@", topBin);
#endif

//#define SELECT_TOP_BID_FROM_TOP_BIN
#ifdef	SELECT_TOP_BID_FROM_TOP_BIN
	// select top bids from the bin
	double				topBidPrice = -1.0;
	NSMutableArray*		topBids = [NSMutableArray array];
	for ( id<AuctionBid> bid in [topBin bids] )
	{
		double		price = [bid price];
		
		if ( price > topBidPrice )
		{
			topBidPrice = price;
			[topBids removeAllObjects];
			[topBids addObject:bid];
		}
		else if ( price == topBidPrice )
			[topBids addObject:bid];
	}
#ifdef DUMP
	NSLog(@"[AuctionManagerImpl] topBids: %@", topBids);
#endif

#else
	NSArray*			topBids = topBin.bids;
#endif
	
	// select a bid
	id<AuctionBid>		topBid = (id<AuctionBid>)[topBids objectAtRandomIndex];
#ifdef DUMP
	NSLog(@"[AuctionManagerImpl] topBid: %@", topBid);
#endif
#ifdef DUMP_TOP_BID
	NSLog(@"[AuctionManagerImpl] topBid: %@", topBid);
#endif
	
	// let bid know it won
	[topBid didWinAuction:article inRoom:room];
	
	
	// return top bid
	return topBid;
}


@end
