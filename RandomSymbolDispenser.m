//
//  RandomSymbolDispenser.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "RandomSymbolDispenser.h"


@implementation RandomSymbolDispenser
@synthesize alphabet = _alphabet;
@synthesize symbolCount;
@synthesize rushSymbols = _rushSymbols;

-(void)dealloc
{
	[_alphabet release];
	[_rushSymbols release];
	
	[super dealloc];
}

-(unichar)dispense:(NSMutableDictionary*)hints
{
	if ( [self canDispense] )
	{
		if ( [self rushDispensing] )
		{
			unichar		ch = [_rushSymbols characterAtIndex:0];
			
			[_rushSymbols deleteCharactersInRange:NSMakeRange(0, 1)];
			
			return ch;
		}
		
		symbolsLeft--;
		
		float	r = (float)rand() / RAND_MAX;
		int		index = [_alphabet size];
		
		while ( --index >= 0 )
		{
			float		weight = [_alphabet weightAt:index];
			
			r -= weight;
			if ( r <= 0 )
				return [_alphabet symbolAt:index];
		}
		
		// if here, return first symbol;
		return [_alphabet symbolAt:0];
	}
	else
		return NO_SYMBOL;
}

-(BOOL)canDispense
{
	return symbolsLeft > 0 || [self rushDispensing];
}

-(void)setSymbolCount:(int)count
{
	symbolCount = count;
	symbolsLeft = count;
}

-(float)progress
{
	return 1.0 - (float)symbolsLeft / symbolCount;
}

-(int)symbolsLeft
{
	return symbolsLeft;
}

-(BOOL)rushDispensing
{
	return _rushSymbols && [_rushSymbols length];
}

@end	
