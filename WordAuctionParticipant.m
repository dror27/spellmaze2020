//
//  WordAuctionParticipant.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WordAuctionParticipant.h"
#import "BoardAuctionArticle.h"
#import "SymbolAuctionBid.h"
#import "GameLevel.h"
#import "CSetWrapper.h"


extern int compare_unichars(const void * a, const void * b);

@interface WordAuctionParticipant (Private)
-(id<AuctionBid>)bidForSymbol:(unichar)symbol;
@end


@implementation WordAuctionParticipant

-(id)initWithWord:(NSString*)word andWordIndex:(int)wordIndex1
{
	if ( self = [super init] )
	{
		_word = [word retain];
		wordIndex = wordIndex1;
		symbolCount = [word length];
		_symbols = malloc(symbolCount * sizeof(unichar));
		[_word getCharacters:_symbols];
		leadingSymbol = _symbols[0];
		qsort(_symbols, symbolCount, sizeof(unichar), compare_unichars);
		
		blackListVersion = -1;
	}
	return self;
}

-(void)dealloc
{
	[_word release];
	free(_symbols);
	
	[super dealloc];
}

-(NSArray*)bid:(id<AuctionArticle>)article withPriceThreshold:(double*)priceThreshold
{		
	if ( blackListed )
		return nil;

	if ( ![article isKindOfClass:[BoardAuctionArticle class]] )
		return nil;
	BoardAuctionArticle*	boardArticle = (BoardAuctionArticle*)article;
	
	// update blackListed
	id<Board>				board = [boardArticle board];
	CSetWrapper*			blackList = [[board level] blackList];
	if ( blackList.cs->version != blackListVersion )
	{
		blackListVersion = blackList.cs->version;
		blackListed = CSet_IsMember(blackList.cs, wordIndex);
	}
	if ( blackListed )
		return nil;
	
	// if a leading is defined, word must start with it
	unichar					boardLeadingSymbol = [boardArticle leadingSymbol];
	if ( boardLeadingSymbol != NO_SYMBOL && boardLeadingSymbol != leadingSymbol )
		return nil;
	 
	 
	// walk on the symbols of the word, issue a bid for every symbol that is missing
	NSMutableArray*	bids = nil;
	unichar*		wordSymbols = _symbols;
	int				wordSymbolCount = symbolCount;
	unichar*		boardSymbols = [boardArticle symbols];
	int				boardSymbolCount = [boardArticle symbolCount];
	int				bidCount = 0;
	double			targetPrice;
	while ( wordSymbolCount > 0 )
	{
		// get next word symbol
		unichar		wordSymbol = *wordSymbols++;
		wordSymbolCount--;
		
		// skip on board symbols until a match or no more symbols left
		while ( boardSymbolCount > 0 && *boardSymbols < wordSymbol )
		{
			boardSymbols++;
			boardSymbolCount--;
		}
		
		// if match found, simply skip it
		if ( boardSymbolCount > 0 && *boardSymbols == wordSymbol ) 
		{
			boardSymbols++;
			boardSymbolCount--;			
		}
		else
		{
			// otherwise, issue a bid
			if ( bids )
				[bids addObject:[self bidForSymbol:wordSymbol]];
			else
				bids = [NSMutableArray arrayWithObject:[self bidForSymbol:wordSymbol]];
			bidCount++;
			targetPrice = 1.0 / bidCount;
			
			// bail out?
			if ( priceThreshold && (*priceThreshold > targetPrice) )
				return nil;		// will never generate an offer greated then then threshold ...
		}
	}
	
	// price bids according to the number of symbols left to complete the word
	if ( bidCount )
	{
		for ( SymbolAuctionBid* bid in bids )
			bid.price = targetPrice;
		
		if ( priceThreshold && targetPrice > *priceThreshold )
			*priceThreshold = targetPrice;
	}
	
	return bids;
}

-(id<AuctionBid>)bidForSymbol:(unichar)symbol
{
	SymbolAuctionBid*	bid = [[[SymbolAuctionBid alloc] initWithSymbol:symbol] autorelease];
	
	bid.participant = self;
	
	return bid;
}

-(BOOL)doneBidding
{
	return blackListed;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<WordAuctionParticipant: 0x%p, %@, %d, %@>", self, _word, symbolCount, [NSString stringWithCharacters:_symbols length:symbolCount]];
}



@end
