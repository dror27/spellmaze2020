//
//  SymbolAlphabet.m
//  Board3
//
//  Created by Dror Kessler on 5/11/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "SymbolAlphabet.h"
#import "NSMutableArray_Shuffle.h"

@interface Entry : NSObject {
	unichar		symbol;
	int			count;
}
@property unichar symbol;
@property int count;
@end

@implementation Entry
@synthesize symbol;
@synthesize count;

-(NSComparisonResult)orderAgainst:(Entry*)other
{
	if ( count < other.count )
		return NSOrderedDescending;
	else if ( count > other.count )
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

@end


@implementation SymbolAlphabet
@synthesize symbols = _symbols;

-(id)init
{
	if ( self = [super self] )
	{
		self.symbols = [[[NSMutableArray alloc] init] autorelease];
		countSum = 0;
	}
	return self;
}

-(void)dealloc
{
	[_symbols release];
	if ( _allSymbols )
		free(_allSymbols);
	
	[super dealloc];
}

-(void)addSymbol:(unichar)symbol withCount:(int)count;
{
	Entry*	entry = [[[Entry alloc] init] autorelease];
	
	entry.symbol = symbol;
	entry.count = count;
	
	countSum += count;
	
	[_symbols addObject:entry]; 
}

-(int)size
{
	return [_symbols count];
}

-(unichar)symbolAt:(int)index
{
	return ((Entry*)[_symbols objectAtIndex:index]).symbol;
}

-(float)weightAt:(int)index
{
	if ( countSum > 0.0 )
		return ((Entry*)[_symbols objectAtIndex:index]).count / (float)countSum;
	else
		return 0.0;
}

-(int)symbolIndex:(unichar)symbol
{
	// TODO: rewrite this trivial implementation
	int		index = 0;
	for ( Entry *entry in _symbols )
		if ( entry.symbol == symbol )
			return index;
		else
			index++;
	return -1;
}

-(unichar*)allSymbols:(AlphabetSymbolOrder)order;
{
	@synchronized (self)
	{
		if ( order == AlphabetSymbolOrderRandom )
		{
			if ( _allSymbols )
				free(_allSymbols);
			_allSymbols = NULL;
		}
		if ( !_allSymbols )
		{
			NSMutableArray*	sorted = [NSMutableArray arrayWithArray:_symbols];
			if ( order == AlphabetSymbolOrderWeights )
				[sorted sortUsingSelector:@selector(orderAgainst:)];
			else if ( order == AlphabetSymbolOrderRandom )
				[sorted shuffle];
			
			// store in memory vector
			int			count = [sorted count];
			_allSymbols = calloc(sizeof(unichar), count);
			int			index = 0;
			//NSLog(@"---------");
			for ( Entry* entry in sorted )
			{
				//NSLog(@"'%C'", entry.symbol);
				_allSymbols[index++] = entry.symbol;
			}
		}
	}
	
	return _allSymbols;
}

@end
