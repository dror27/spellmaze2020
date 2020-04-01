//
//  AuctionManagerImpl.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionManager.h"

typedef enum {
	
	AuctionManagerImplAggregationTypeHorizontal = 0,		// meaning spreading wide
	AuctionManagerImplAggregationTypeVertical = 1			// meaning closing in on words as fast as possible
	
} AuctionManagerImplAggregationType;

@interface AuctionManagerImpl : NSObject<AuctionManager> {

	AuctionManagerImplAggregationType	aggregationType;
}

@end
