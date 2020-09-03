//
//  WordCountBPF.m
//  Board3
//
//  Created by Dror Kessler on 7/21/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "WordCountBPF.h"
#import "BPF_Entry.h"
#import "GameLevel.h"
#import "Language.h"
#import "CSetWrapper.h"

static BOOL		localLog = FALSE;

@implementation WordCountBPF

-(NSArray*)potentialsFor:(NSString*)boardSymbols withSymbolFromLanguage:(id<Language>)language 
									withPrefixEntry:(BPF_Entry*)prefixEntry  withMinSize:(int)minSize andBlackList:(CSetWrapper*)blackList
{
	id<Alphabet>		alphabet = [language alphabet];
	NSMutableArray*		result = [[[NSMutableArray alloc] init] autorelease];
	int					count = [alphabet size];
	
	// get pieces on the board & extract symbols
	NSMutableString *symbols = [[[NSMutableString alloc] initWithString:boardSymbols] autorelease];
	for ( BPF_Entry* entry = prefixEntry ; entry ; entry = entry.prefix )
		[symbols appendFormat:@"%C", entry.symbol];
	int				charsNum = [symbols length];
	unichar			*chars = calloc(charsNum + 2, sizeof(unichar));
	[symbols getCharacters:chars];
	/*
	if ( localLog )
		NSLog(@"Symbols: %@", symbols);
	 */

	// get score of board as it is right now
	CSetWrapper		*wordsSet = [language getValidWordSet:chars withCharsNum:charsNum withMinWordSize:minSize withMaxWordSize:0 andBlackList:blackList];
	float			baseScore = wordsSet.cs->size;
	
	for ( int index = 0 ; index < count ; index++ )
	{
		unichar			symbol = [alphabet symbolAt:index];
		float			weight = [alphabet weightAt:index];
	
		// build entry
		BPF_Entry* entry = [[[BPF_Entry alloc] init] autorelease];
		entry.symbol = symbol;
		entry.weight = weight;
		entry.prefix = prefixEntry;
	
		// score it
		chars[charsNum] = symbol;
		CSetWrapper		*wordsSet = [language getValidWordSet:chars withCharsNum:charsNum+1 withMinWordSize:minSize withMaxWordSize:0 andBlackList:blackList];
		
		if ( localLog )
			[wordsSet NSLogWithElementsNames:[language getAllWords] andPrefix:@""];
		
		entry.score = wordsSet.cs->size - baseScore;
		if ( entry.prefix )
			entry.score += entry.prefix.score;
		
		if ( localLog )
			NSLog(@"WordCountBPF: potentials: '%S' - %f, %f", chars, entry.weight, entry.score);
		
		// add it
		[result addObject:entry];
	}
	
	[result sortUsingSelector:@selector(orderAgainst:)];
	
	free(chars);
	
	return result;
}


@end
