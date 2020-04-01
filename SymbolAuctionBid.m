//
//  SymbolAuctionBid.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SymbolAuctionBid.h"


@implementation SymbolAuctionBid
@synthesize price;
@synthesize participant = _participant;

-(id)initWithSymbol:(unichar)symbol1
{
	if ( self = [super init] )
	{
		symbol = symbol1;
		_key = [[NSNumber numberWithUnsignedChar:symbol] retain];
	}
	return self;
}

-(void)dealloc
{
	[_key release];
	[_participant release];
	
	[super dealloc];
}

-(unichar)symbol
{
	return symbol;
}

-(NSObject*)key
{
	return _key;
}

-(void)didWinAuction:(id<AuctionArticle>)article inRoom:(id<AuctionRoom>)room
{
	
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<SymbolAuctionBid: 0x%p, '%C', %f, %@>", self, symbol, price, _participant];
}

@end
