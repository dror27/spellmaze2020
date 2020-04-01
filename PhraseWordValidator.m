//
//  PhraseWordValidator.m
//  Board3
//
//  Created by Dror Kessler on 7/20/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PhraseWordValidator.h"
#import "CSetWrapper.h"

@implementation PhraseWordValidator
@synthesize phrase = _phrase;
@synthesize words = _words;

-(void)dealloc
{
	[_phrase release];
	[_words release];
	
	[super dealloc];
}

-(NSString*)isValidWord:(NSString*)word withBlackList:(CSetWrapper*)blackList withWhiteListWords:(NSSet*)whiteListWords
{
	// TODO: is the black list significant here ... (this class might not be in use anymore ...)
	
	if ( !_words || currentWordIndex >= [_words count] )
		return NULL;
	else 
	{
		if ( [whiteListWords count] && ![whiteListWords containsObject:word] )
			return NULL;
		return [word isEqualToString:[_words objectAtIndex:currentWordIndex]] ? word : NULL;
	}
}

-(CSetWrapper*)getValidWordSet:(unichar*)chars withCharsNum:(int)charsNum withMinWordSize:(int)minWordSize withMaxWordSize:(int)maxWordSize andBlackList:(CSetWrapper*)blackList
{
	CSetWrapper*	csw = [[[CSetWrapper alloc] init] autorelease];
	
	if ( !_words || currentWordIndex >= [_words count] )
	{
	}
	else
		CSet_AddElement(csw.cs, currentWordIndex);
	
	return csw;
}

-(NSString*)getValidWordByIndex:(int)index
{
	if ( !_words || currentWordIndex >= [_words count] )
	{
		return @"";
	}
	else
		return [_words objectAtIndex:index];
}

-(void)wordDispensed:(NSString*)word
{
	// store phrase
	self.phrase = word;
	
	// break into words
	self.words = [_phrase componentsSeparatedByString:@" "];
	
	// init other
	currentWordIndex = 0;
}

-(void)wordCompleted:(NSString*)word
{
	// move to next word
	currentWordIndex++;
}

-(NSString*)wordForHintWord:(NSString*)word
{
	return _phrase;
}

-(unichar)getValidWordCharacterByIndex:(int)index characterAt:(int)charIndex
{
	return [[self getValidWordByIndex:index] characterAtIndex:charIndex];
}


@end
