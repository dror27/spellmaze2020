//
//  AuctionParticipant.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionArticle.h"

@protocol AuctionParticipant<NSObject>

-(NSArray*)bid:(id<AuctionArticle>)article withPriceThreshold:(double*)priceThreshold;

-(BOOL)doneBidding;

@end
