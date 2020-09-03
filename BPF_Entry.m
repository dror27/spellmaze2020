//
//  BPF_Entry.m
//  Board3
//
//  Created by Dror Kessler on 7/21/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "BPF_Entry.h"


@implementation BPF_Entry
@synthesize symbol;
@synthesize weight;
@synthesize score;
@synthesize prefix = _prefix;

-(void)dealloc
{
	[_prefix release];
	
	[super dealloc];
}

-(NSComparisonResult)orderAgainst:(BPF_Entry*)other
{
	if ( score < other.score )
		return NSOrderedDescending;
	else if ( score > other.score )
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

-(unichar)prefixSymbol
{
	if ( _prefix )
		return [_prefix prefixSymbol];
	else
		return symbol;
}

-(NSString*)prefixString
{
	if ( _prefix )
		return [[_prefix prefixString] stringByAppendingString:[NSString stringWithCharacters:&symbol length:1]];
	else
		return [NSString stringWithCharacters:&symbol length:1];
}
@end
