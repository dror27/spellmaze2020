//
//  WordQueue.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/25/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "WordQueue.h"
#import "NSMutableArray_Shuffle.h"

//#define DUMP

@implementation WordQueue
@synthesize prepWords = _prepWords;
@synthesize language = _language;

-(id)initWithLanguageWords:(id<Language>)language withMinSize:(int)minSize andMaxSize:(int)maxSize andBlackList:(CSetWrapper*)blackList
{
	if ( self = [super init] )
	{
		CSet*		minMax = [language getMinMaxWordsCS:minSize withMaxWordSize:maxSize];
		CSet*		blackListCS = blackList.cs;
		
		_wordsCS = CSet_NegativeIntersect(minMax, &blackListCS, 1, NULL);
		self.prepWords = [NSMutableArray array];
		self.language = language;
		
#ifdef DUMP
		NSLog(@"[WordQueue] initWithLanguageWords %d-%d (%d) -> %d", minSize, maxSize, blackList.cs->size, _wordsCS->size);
#endif
	}
	return self;
}

-(void)dealloc
{
	free(_wordsCS);
	[_prepWords release];
	[_language release];
	
	[super dealloc];
}

-(BOOL)hasWords
{
	return _wordsCS->size || [_prepWords count];
}

-(NSString*)nextWord
{
	// prepare?
	if ( ![_prepWords count] )
	{
		int		prepChunkSize = 20;
		
		// all in one shot?
		if ( prepChunkSize >= _wordsCS->size )
		{
			// copy all words out
			for ( int elemIndex = _wordsCS->size - 1 ; elemIndex >= 0 ; elemIndex-- )
				[_prepWords addObject:[_language getWordByIndex:_wordsCS->elems[elemIndex]]];
			_wordsCS->size = 0;
		}
		else if ( _wordsCS->size > 0 )
		{
			// pick out random words, mark taken words with +inf (0x7FFFFFFF)
			for ( ; prepChunkSize > 0 ; prepChunkSize-- )
			{
				int		elemIndex = rand() % _wordsCS->size;
				int		wordIndex = _wordsCS->elems[elemIndex];
				
				if ( wordIndex >= 0 && wordIndex != 0x7FFFFFFF )
				{
					[_prepWords addObject:[_language getWordByIndex:wordIndex]];
					_wordsCS->elems[elemIndex] = 0x7FFFFFFF;
				}
			}
			
			// remove marked slots
			_wordsCS->sorted = FALSE;
			CSet_RemoveDuplicates(_wordsCS);
			if ( _wordsCS->size && (_wordsCS->elems[_wordsCS->size - 1] == 0x7FFFFFFF) )
				_wordsCS->size--;
		}
		
		// still empty?
		if ( ![_prepWords count] )
			return nil;
				
		// shuffle prep words
		[_prepWords shuffle];
#ifdef DUMP
		NSLog(@"[WordQueue] new chunk: %@", _prepWords);
#endif
	}
	
	// return
	NSString*		word = [[[_prepWords lastObject] retain] autorelease];
	[_prepWords removeLastObject];

#ifdef DUMP
	NSLog(@"[WordQueue] nextWord: %@", word);
#endif
	return word;
}


@end
