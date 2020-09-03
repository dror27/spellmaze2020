//
//  ConstantBoardPotentialFunction.m
//  Board3
//
//  Created by Dror Kessler on 7/16/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "ConstantBoardPotentialFunction.h"
#import "BPF_Entry.h"

@implementation ConstantBoardPotentialFunction
@synthesize thePotential;

-(NSArray*)potentialsFor:(NSString*)boardSymbols withSymbolFromLanguage:(id<Language>)language 
		 withPrefixEntry:(BPF_Entry*)prefixEntry withMinSize:(int)minSize andBlackList:(CSetWrapper*)blackList
{
	id<Alphabet>		alphabet = [language alphabet];
	NSMutableArray*		result = [[[NSMutableArray alloc] init] autorelease];
	int					count = [alphabet size];
	
	for ( int index = 0 ; index < count ; index++ )
	{
		unichar			symbol = [alphabet symbolAt:index];
		float			weight = [alphabet weightAt:index];
		
		// build entry
		BPF_Entry* entry = [[[BPF_Entry alloc] init] autorelease];
		entry.symbol = symbol;
		entry.weight = weight;
		entry.score = thePotential;
		entry.prefix = prefixEntry;
		[result addObject:entry];
	}
	
	[result sortUsingSelector:@selector(orderAgainst:)];
	
	return result;
}

@end
