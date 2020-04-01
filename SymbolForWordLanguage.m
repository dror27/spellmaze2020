//
//  SymbolForWordLanguage.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SymbolForWordLanguage.h"
#import "SymbolAlphabet.h"
#import "CSet.h"
#import "CSetWrapper.h"

@implementation SymbolForWordLanguage
@synthesize base = _base;
@synthesize alphabet = _alphabet;
@synthesize allWords = _allWords;
@synthesize wordsOrigin = _wordsOrigin;

-(id)initWithBaseLanguage:(id<Language>)base
{
	if ( self = [super init] )
	{
		self.base = base;
		
		// build alphabet, allWords, etc
		wordCount = [_base wordCount];
		self.alphabet = [[[SymbolAlphabet alloc] init] autorelease];
		self.wordsOrigin = [NSMutableDictionary dictionary];
		NSMutableArray*	allWords = [NSMutableArray array];
		for ( int index = 0 ; index < wordCount ; index++ )
		{
			unichar		symbol = index;
			
			[_alphabet addSymbol:symbol withCount:1];
			
			[allWords addObject:[NSString stringWithCharacters:&symbol length:1]];
		}
		self.allWords = allWords;
	}
	return self;
}

-(void)dealloc
{
	[_base release];
	[_alphabet release];
	[_allWords release];
	[_wordsOrigin release];
	
	[super dealloc];
}

-(NSString*)name
{
	return [_base name];
}

-(NSString*)uuid
{
	return [_base uuid];
}

-(NSString*)uuidFolder
{
	return [_base uuidFolder];
}

-(id<Alphabet>)alphabet
{
	return _alphabet;
}

-(NSString*)getWordByIndex:(int)index
{
	return [_allWords objectAtIndex:index];
}

-(NSArray*)getAllWords
{
	return _allWords;
}

-(int)wordCount
{
	return wordCount;
}

-(int)wordIndex:(NSString*)word
{
	return [_allWords indexOfObject:word];
}

-(BOOL)rtl
{
	return [_base rtl];
}

-(UIImage*)wordImage:(NSString*)word
{
	return [_base wordImage:[_base getWordByIndex:[self wordIndex:word]]];
}

-(UIImage*)symbolImage:(unichar)symbol
{
	return [_base wordImage:[_base getWordByIndex:symbol]];
}

-(BOOL)showSymbolTextOnSymbolImage
{
	return FALSE;
}

-(NSURL*)wordSoundUrl:(NSString*)word
{
	return [_base wordSoundUrl:[_base getWordByIndex:[self wordIndex:word]]];	
}

-(BOOL)allowAddWord
{
	return FALSE;
}

-(void)addWord:(NSString*)word
{
	
}

-(void)addWordImage:(id<NSObject>)imageSpec toWord:(NSString*)word
{
	
}

-(NSString*)getRandomWord:(int)minSize withMaxSize:(int)maxSize withBlackList:(CSetWrapper*)blackList;
{
	return [_allWords objectAtIndex:rand() % wordCount];
}

-(NSMutableDictionary*)wordsOrigin
{
	return _wordsOrigin;
}

-(NSString*)isValidWord:(NSString*)word withBlackList:(CSetWrapper*)blackList withWhiteListWords:(NSSet*)whiteListWords;
{
	if ( [word length] != 1 )
		return NULL;
	
	int		index = [word characterAtIndex:0];
	if ( index < 0 || index >= wordCount )
		return NULL;
	
	if ( blackList && CSet_IsMember(blackList.cs, index) )
		return NULL;
	
	return word;
}

-(CSetWrapper*)getValidWordSet:(const unichar*)chars withCharsNum:(int)charsNum withMinWordSize:(int)minWordSize withMaxWordSize:(int)maxWordSize andBlackList:(CSetWrapper*)blackList;
{
	CSetWrapper*	csw = [[[CSetWrapper alloc] init] autorelease];
	
	// walk the chars, add
	while ( charsNum-- )
	{
		unichar		index = *chars++;
		
		// on black list?
		if ( blackList && CSet_IsMember(blackList.cs, index) )
			continue;
		
		// add it (removing dups later)
		CSet_AddElement(csw.cs, index);
	}
	CSet_RemoveDuplicates(csw.cs);
	
	return csw;
}

-(NSString*)getValidWordByIndex:(int)index
{
	return [self getWordByIndex:index];
}

-(unichar)getValidWordCharacterByIndex:(int)index characterAt:(int)charIndex
{
	return [[self getWordByIndex:index] characterAtIndex:charIndex];
}

-(void)wordDispensed:(NSString*)word
{
	
}

-(void)wordCompleted:(NSString*)word
{
	
}

-(NSString*)wordForHintWord:(NSString*)word
{
	if ( !word || [word length] != 1 )
		return @"";
	
	int			index = [self wordIndex:word];
	if ( index < 0 || index >= wordCount )
		return @"";
	
	return [_base getWordByIndex:index];
}

-(int)maxWordSize
{
	return 1;
}

-(NSString*)voiceLanguage
{
	return [_base voiceLanguage];
}

-(NSDictionary*)props
{
	return [_base props];
}

-(int)getWordCount:(int)minSize withMaxSize:(int)maxSize
{
	return [_base getWordCount:minSize withMaxSize:maxSize];
}

-(NSDictionary*)wordMetaData:(NSString*)word
{
	return [_base wordMetaData:[_base getWordByIndex:[self wordIndex:word]]];
}

-(CSet*)getMinMaxWordsCS:(int)minWordSize withMaxWordSize:(int)maxWordSize
{
	return [_base getMinMaxWordsCS:minWordSize withMaxWordSize:maxWordSize];
}

@end
