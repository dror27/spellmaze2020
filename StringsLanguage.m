//
//  StringsLanguage.m
//  Board3
//
//  Created by Dror Kessler on 5/9/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import <objc/runtime.h>
#import <stdlib.h>
#import "StringsLanguage.h"
#import "CSetWrapper.h"
#import "UserPrefs.h"
#import "Folders.h"
#import <wchar.h>
#import <math.h>
#import "JokerUtils.h"
#import "NSDictionary_TypedAccess.h"
#import "SystemUtils.h"
#import "ImageWithUUID.h"
#import "UUIDUtils.h"

//#define	DUMP
//#define		LIGHT_DUMP

//#define		ALLOC_COUNT
#ifdef		ALLOC_COUNT
static int			initCount;
static int			deallocCount;
#endif

//HACK
//#define MEASURE
#ifdef	MEASURE
static clock_t		startedAt;
#endif


static void unichar_toupper(unichar* line)
{
	unichar*	p = line;
	unichar		ch;
	while ( ch = *p )
		*p++ = towupper(ch);	
}

static unichar* unichar_strtok2(unichar* string, unichar sep1, unichar sep2, unichar** context)
{
	unichar*	tok_start;
	unichar*	tok_end;
	
	// get starting point
	if ( string )
		tok_start = string;
	else if ( !*context )
		return NULL;
	else
		tok_start = *context;
	
	// skip till next non-seps
	unichar		ch;
	while ( ch = *tok_start )
		if ( ch == sep1 || ch == sep2 )
			tok_start++;
		else
			break;
	
	// end of string?
	if ( !ch )
		return NULL;
	
	// find end of tok
	tok_end = tok_start + 1;
	while ( ch = *tok_end )
		if ( ch == sep1 || ch == sep2 )
			break;
		else
			tok_end++;
	
	// setup context
	if ( ch )
		*context = tok_end + 1;
	else
		*context = NULL;
	
	// terminate token
	*tok_end = '\0';
	
	// return token
	return tok_start;
}


static unichar* unichar_strchr2(unichar* string, unichar ch1, unichar ch2)
{
	unichar		ch;
	
	while ( ch = *string++ )
		if ( ch == ch1 || ch == ch2 )
			return string - 1;
	
	return NULL;
}

static int unichar_strlen(unichar* string)
{
	int		len = 0;
	
	while ( *string++ )
		len++;
	
	return len;
}

static unichar* unichar_trim(unichar* line, int* lineLengthReturn)
{
	while ( *line == ' ' )
		line++;
	int			lineLength = unichar_strlen(line);
	while ( lineLength && line[lineLength - 1] == ' ' )
		lineLength--;
	line[lineLength] = '\0';
	
	if ( lineLengthReturn )
		*lineLengthReturn = lineLength;
	
	return line;
}

static NSString* unichar_NSString(unichar* line)
{
	return [[[NSString alloc] initWithCharactersNoCopy:line length:unichar_strlen(line) freeWhenDone:FALSE] autorelease];
}



@interface StringsLanguage (Privates)
-(void)_fillWithStringArrayInternal:(NSArray*)array;
-(void)_fillWithUnicharStringCSetInternal;
-(void)groupChars:(const unichar*)chars withCharsNum:(int)charsNum into:(unichar*)groupedChars;
-(NSString*)stringFromWordArray:(NSArray*)array withPrefix:(NSString*)prefix andSuffix:(NSString*)suffix;
-(void)loadProps;
@end




@implementation StringsLanguage
@synthesize uuid = _uuid;
@synthesize allValid = _allValid;
@synthesize rtl = _rtl;
@synthesize minWordLength = _minWordLength;
@synthesize splitWords = _splitWords;
@synthesize allCaps = _allCaps;
@synthesize textDelimiter = _textDelimiter;
@synthesize allowAddWord = _allowAddWord;
@synthesize allWordsOverride = _allWordsOverride;
@synthesize name = _name;
@synthesize voiceLanguage = _voiceLanguage;


@synthesize uuidFolder = _uuidFolder;
@synthesize props = _props;
@synthesize alphabet = _alphabet;
@synthesize words = _words;
@synthesize wordLengthMax = _wordLengthMax;
@synthesize wordSymbolsSets = _wordSymbolsSets;
@synthesize wordLengthSets = _wordLengthSets;
@synthesize wordImages = _wordImages;
@synthesize symbolImages = _symbolImages;
@synthesize wordsOrigin = _wordsOrigin;
@synthesize allWordsSet = _allWordsSet;
@synthesize filePath = _filePath;
@synthesize jitAllWords = _jitAllWords;
@synthesize minMaxWordSets = _minMaxWordSets;
@synthesize texts = _texts;
@synthesize titles = _titles;

-(id)initWithStringsArray:(NSArray*)array
{
	// convert to string ... - easier for now (also less used)
	return [self initWithStringsString:[self stringFromWordArray:array withPrefix:NULL andSuffix:NULL]];
}

-(id)initWithStringsString:(NSString*)strings
{
	
#ifdef	ALLOC_COUNT
	initCount++;
	NSLog(@"[StringsLanguage-%p] init: init/dealloc = %d/%d", self, initCount, deallocCount);
#endif
	
	if ( self = [super init] )
	{	
#ifdef DUMP
		NSLog(@"[StringsLanguage] Parsing into array of words ...");
#endif		
		// do some initial allocation
		self.wordsOrigin = [[[NSMutableDictionary alloc] init] autorelease];
		self.words = [[[CSetWrapper alloc] initWithCSet:CSet_Alloc(0x4000)] autorelease];
		self.words.cs->compare = CSet__UnicharStringCompare;
		self.wordLengthMax = 0;
		CSet*	words = self.words.cs;	// cache access
		
		// get white list
		int				whiteListLength = 0;
		NSString*		whiteListStrings = NULL;
		NSArray*		whiteList = [UserPrefs getArray:[UserPrefs key:PK_LANG_WHITELIST forUuid:self.uuid] withDefault:NULL];
		if ( whiteList && [whiteList count] )
		{
			whiteListStrings = [self stringFromWordArray:whiteList withPrefix:@"\n" andSuffix:@"\n"];
			whiteListLength = [whiteListStrings length];
#ifdef DUMP
			NSLog(@"[StringsLanguage] whiteListStrings: %@", whiteListStrings);
#endif
		}
		
		// has texts?
		unichar		textDelimiterChar = 0;
		if ( _textDelimiter && [_textDelimiter length] == 1 )
			textDelimiterChar = [_textDelimiter characterAtIndex:0];
		
		int				length = [strings length] + whiteListLength;
		unichar*		buf = malloc((length + 1) * sizeof(unichar));
		self->_buf = buf;
		[strings getCharacters:buf];
		if ( whiteListLength )
			[whiteListStrings getCharacters:buf + [strings length]];
		buf[length] = '\0';
		unichar*		context;
		unichar*		line = unichar_strtok2(buf, '\n', '\r', &context);
		BOOL			allCapsPerformed;
		for ( ; line ; line = unichar_strtok2(NULL, '\n', '\r', &context) )
		{
			int		lineLength = 0;
			// trim
			line = unichar_trim(line, &lineLength);
			
			// empty/comment?
			if ( !lineLength || line[0] == '#' )
				continue;
			
			// split text?
			unichar*	text = NULL;
			unichar*	title = NULL;
			if ( textDelimiterChar )
			{
				unichar*	tokContext;
				unichar*	tok1 = unichar_strtok2(line, textDelimiterChar, 0, &tokContext);
				
				title = unichar_strtok2(NULL, textDelimiterChar, 0, &tokContext);
				text = unichar_strtok2(NULL, textDelimiterChar, 0, &tokContext);
				
				if ( !text && title )
				{
					// text has priority ...
					text = title;
					title = NULL;
				}
				
				if ( title )
					title = unichar_trim(title, NULL);
				if ( text )
					text = unichar_trim(text, NULL);
				line = tok1;
				line = unichar_trim(line, &lineLength);
				
				if ( title || text )
				{
					if ( _allCaps )
					{
						unichar_toupper(line);
						allCapsPerformed = TRUE;
					}
					
					NSString*	word = unichar_NSString(line);
					
					
					if ( title )
					{
						if ( !_titles )
							self.titles = [NSMutableDictionary dictionary];
						[_titles setObject:unichar_NSString(title) forKey:word];
					}
					if ( text )
					{
						if ( !_texts )
							self.texts = [NSMutableDictionary dictionary];
						[_texts setObject:unichar_NSString(text) forKey:word];
					}
					
				}
					
				
			}
			
			// allcaps?
			if ( _allCaps && !allCapsPerformed )
				unichar_toupper(line);
			
			// split on spaces and tabs?
			if ( !_splitWords || !unichar_strchr2(line, ' ', '\t') )
			{
				// add to set
				//NSLog([NSString stringWithCharacters:line length:unichar_strlen(line)]);
				CSet_AddElement(words, (T_ELEM)line);
			}
			else 
			{
				NSString*		originalWord = [NSString stringWithCharacters:line length:lineLength];
				unichar*		splitContext;
				unichar*		splitWord = unichar_strtok2(line, ' ', '\t', &splitContext);
				
				for ( ; splitWord ; splitWord = unichar_strtok2(NULL, ' ', '\t', &splitContext) )
				{
					int			len = unichar_strlen(splitWord);
					CSet_AddElement(words, (T_ELEM)splitWord);

					NSString*	word = [NSString stringWithCharacters:splitWord length:len];
					
					NSMutableArray*		originalWords = [self.wordsOrigin objectForKey:word];
					if ( !originalWords )
						[self.wordsOrigin setObject:(originalWords = [[[NSMutableArray alloc] init] autorelease]) forKey:word];
					[originalWords addObject:originalWord];
				}
			}
			if ( lineLength > _wordLengthMax )	// this does not have to be really tight ... just large enough
				_wordLengthMax = lineLength;
		}
		
		[self _fillWithUnicharStringCSetInternal];
	}
	
	return self;
}

-(id)initWithStringsFile:(NSString*)path
{
	self.filePath = path;
	
	// read words in
#ifdef DUMP
	NSLog(@"[StringsLanguage] Reading file: %@", path);
#endif
	NSError		*error;
	NSString	*strings = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	if ( !strings )
		NSLog(@"[StringsLanguage] Missing file: %@\n  error: %@", path, error);
	
	return [self initWithStringsString:strings];
}

-(void)dealloc
{
#ifdef	ALLOC_COUNT
	deallocCount++;
	NSLog(@"[StringsLanguage-%p] dealloc: init/dealloc = %d/%d", self, initCount, deallocCount);
#endif
	
	[_uuid release];
	[_allWordsOverride release];
	[_uuidFolder release];
	[_props release];
	[_alphabet release];
	[_words release];
	[_wordSymbolsSets release];
	[_wordLengthSets release];
	[_wordImages release];
	[_symbolImages release];
	[_wordsOrigin release];
	[_allWordsSet release];
	[_filePath release];
	[_jitAllWords release];
	[_minMaxWordSets release];
	[_name release];
	[_textDelimiter release];
	
	[_texts release];
	[_titles release];
	
	if ( _buf )
		free(_buf);
	
	[super dealloc];
}

-(void)_fillWithUnicharStringCSetInternal
{
	CSet*		words = self.words.cs;
	
	// we arraive here with the words CSet already initialized
	CSet_SortElements(words);
	if ( _allCaps || _splitWords )
		CSet_RemoveDuplicates(words);
#ifdef	DUMP
	for ( int wordIndex = 0 ; wordIndex < MIN(words->size, 100) ; wordIndex++ )
		NSLog(@"word: %S", (unichar*)words->elems[wordIndex]);
#endif
	
	// allocate stuff
	self.wordImages = [[[NSMutableDictionary alloc] init] autorelease];
	self.symbolImages = [[[NSMutableDictionary alloc] init] autorelease];
	self.wordLengthSets = [[[NSMutableArray alloc] init] autorelease];
	self.wordSymbolsSets = [[[NSMutableArray alloc] init] autorelease];
	
	int*			freq = (int*)calloc(0x10000, sizeof(int));
	unichar*		chars;

	
	// loop on words
#ifdef DUMP
	NSLog(@"[StringsLanguage] Determining symbol frequencies ...");
#endif
	int			wordCount = words->size;
	for ( int wordIndex = 0 ; wordIndex < wordCount ; wordIndex++ )
	{
		// extract letters
		chars = (unichar*)words->elems[wordIndex];
		int			charNum = 0;
		unichar		ch;
		while ( ch = *chars++ )
		{
			freq[ch]++;
			charNum++;
		}
		chars -= (charNum + 1);		
	}	
	
	// figure out alphabet
#ifdef DUMP
	NSLog(@"[StringsLanguage] Building alphabet ...");
#endif
	self.alphabet = [[[SymbolAlphabet alloc] init] autorelease];
	for ( int index = 0 ; index < 0x10000 ; index++ )
		if ( freq[index] )
		{
			unichar		ch = (unichar)index;
			
			[((SymbolAlphabet*)_alphabet) addSymbol:ch withCount:freq[index]];
#ifdef DUMP
			NSLog(@"alphabet: %C %d", ch, freq[index]); 
#endif
		}
	
	// build word symbol sets
#ifdef DUMP
	NSLog(@"[StringsLanguage] Building word symbol sets ...");
#endif
	int					symbolsCount = [_alphabet size];
	unichar*			groupedChars = alloca((_wordLengthMax + 1) * sizeof(unichar));
	
	// use sets for intermidiate computations (to speed things up)
	CSet*				lengthSets = CSet_Alloc(0);
	CSet*				symbolsSets = CSet_Alloc(0);

	lengthSets->compare = NULL;		// make sets into vectors (by not being able to sort)
	symbolsSets->compare = NULL;
	
	// reuse freq as a reverse index for moving from a symbol to its index
	for ( int symbolIndex = 0 ; symbolIndex < symbolsCount ; symbolIndex++ )
	{
		unichar		symbol = [_alphabet symbolAt:symbolIndex];
		
		freq[symbol] = symbolIndex;
	}
	
	for ( int wordIndex = 0 ; wordIndex < words->size ; wordIndex++ )
	{
		// access word
		unichar*		word = (unichar*)words->elems[wordIndex];
		
		// enter word into the corrosponding 'length' set
		int				wordLength = unichar_strlen(word);
		
		while ( lengthSets->size < (wordLength + 1) )
		{
			CSet*		cs = CSet_Alloc(0x100);
			cs->sorted = FALSE;
			CSet_AddElement(lengthSets, (T_ELEM)cs);
		}
		CSet_AddElement((CSet*)lengthSets->elems[wordLength], wordIndex);
		
		// order symbols within word by sorting order to get repeating symbols to be consecutive
		unichar*	chars = word;
		int			charsNum = wordLength;
		[self groupChars:chars withCharsNum:charsNum into:groupedChars];
		
		// scan sorted symbols, unify repeating symbols
		int			repeatCount = 0;
		unichar		lastChar = 0;
		for ( int charIndex = 0 ; charIndex < charsNum ; )
		{
			unichar			ch = groupedChars[charIndex++];
			
			// about to change?
			if ( charIndex >= charsNum || groupedChars[charIndex] != ch )
			{
				// handle this symbol
				int			setIndex = freq[ch] + repeatCount * symbolsCount;
				
				// make sure we have such a set, round up to include complete symbol set
				while ( symbolsSets->size < (setIndex + 1) || (symbolsSets->size % symbolsCount) )
				{
					CSet*		cs = CSet_Alloc(0x100);
					cs->sorted = FALSE;
					CSet_AddElement(symbolsSets, (T_ELEM)cs);
				}
				
				// add this word to the set
				CSet_AddElement((CSet*)symbolsSets->elems[setIndex], wordIndex);
				
				// reset repeat count
				repeatCount = 0;
			}
			else
				repeatCount++;
			
			// move to next
			lastChar = ch;
		}
	}
	
	// copy back to NSObject sets
	for ( int i = 0 ; i < lengthSets->size ; i++ )
		[_wordLengthSets addObject:[[[CSetWrapper alloc] initWithCSet:(CSet*)lengthSets->elems[i]] autorelease]];
	for ( int i = 0 ; i < symbolsSets->size ; i++ )
		[_wordSymbolsSets addObject:[[[CSetWrapper alloc] initWithCSet:(CSet*)symbolsSets->elems[i]] autorelease]];
	CSet_Free(lengthSets);
	CSet_Free(symbolsSets);
	lengthSets = NULL;
	symbolsSets = NULL;
	
#ifdef DUMP
	for ( int setIndex = 0 ; setIndex < [_wordSymbolsSets count] ; setIndex++ )
	{
		CSetWrapper*	w = [_wordSymbolsSets objectAtIndex:setIndex];
		
		int				repeat = 1, index = setIndex;
		while ( index >= [_alphabet size] )
		{
			repeat++;
			index -= [_alphabet size];
		}
		
		NSMutableString*	symbols = [[[NSMutableString alloc] init] autorelease];
		unichar				symbol = [_alphabet symbolAt:index];
		for ( ; repeat ; repeat-- )
			[symbols appendFormat:@"%C", symbol];
		
		[w NSLogWithElementsNames:[self getAllWords] andPrefix:symbols];
	}
#endif
	
	// fold sets with higher repeat into sets with lower repeat
#ifdef DUMP
	NSLog(@"[StringsLanguage] Folding sets with higher repeat into sets with lower repeat ...");
#endif
	int			setIndexMax = [_wordSymbolsSets count] - symbolsCount;
	for ( int setIndex = setIndexMax - 1 ; setIndex >= 0 ; setIndex-- )
	{
		CSetWrapper*	lower = [_wordSymbolsSets objectAtIndex:setIndex];
		CSetWrapper*	higher = [_wordSymbolsSets objectAtIndex:setIndex + symbolsCount];
		
		CSet_AddAllElements(lower.cs, higher.cs);
	}
	
	
#ifdef DUMP
	NSLog(@"[StringsLanguage] Creating all set");
#endif
	// build the 'all word indexes' set
	self.allWordsSet = [[[CSetWrapper alloc] initWithInitialAllocation:words->size andSorted:TRUE] autorelease];
	CSet*			allWordsCS = _allWordsSet.cs;
	T_ELEM*			p = allWordsCS->elems;
	int				size = allWordsCS->size = words->size;
	int				index = 0;
	while ( size-- )
		*p++ = index++;
	
	// schedule inverted set preperation on a seperate thread
	[SystemUtils threadWithTarget:self selector:@selector(prepareInverted:) object:self];
	//[NSThread detachNewThreadSelector:@selector(prepareInverted:) toTarget:self withObject:self];	

	
#ifdef DUMP
	for ( int setIndex = 0 ; setIndex < [_wordSymbolsSets count] ; setIndex++ )
	{
		CSetWrapper*	w = [_wordSymbolsSets objectAtIndex:setIndex];
		
		int				repeat = 1, index = setIndex;
		while ( index >= [_alphabet size] )
		{
			repeat++;
			index -= [_alphabet size];
		}
		
		NSMutableString*	symbols = [[[NSMutableString alloc] init] autorelease];
		unichar				symbol = [_alphabet symbolAt:index];
		for ( ; repeat ; repeat-- )
			[symbols appendFormat:@"%C", symbol];
		
		[w NSLogWithElementsNames:[self getAllWords] andPrefix:symbols];
	}
#endif
	
#ifdef DUMP
	NSLog(@"[StringsLanguage] Done (with StringsLangauge prep ...)");
#endif
	
	// free stuff
	free(freq);
}

-(void)prepareInverted:(id)sender
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];

#ifdef DUMP
	NSLog(@"[StringsLanguage] Creating inverted sets");
#endif
	CSet*		allWordsCS = _allWordsSet.cs;
	
	int			maxIndex = [_wordSymbolsSets count];
	if ( maxIndex > [_alphabet size] )
		maxIndex = [_alphabet size];
	
	for ( int setIndex = 0 ; setIndex < maxIndex ; setIndex++ )
	{
		CSetWrapper*	w = [_wordSymbolsSets objectAtIndex:setIndex];
		
		//NSLog(@"Inverting [%d] %p - %@ (%d) against (%d)", setIndex, w, w, w.cs->size, allWordsCS->size);
	
		[w invertedCS:allWordsCS];
	}
#ifdef DUMP
	NSLog(@"[StringsLanguage] Creating inverted sets - DONE");
#endif	
	[pool release];
}

-(id<Alphabet>)alphabet
{
	return _alphabet;
}

-(NSString*)isValidWord:(NSString*)word withBlackList:(CSetWrapper*)blackList withWhiteListWords:(NSSet*)whiteListWords;
{
	if ( _allValid )
		return word;
	
	// copy chars
	int			charNum = [word length];
	unichar*	chars = alloca((charNum + 1) * sizeof(unichar));
	[word getCharacters:chars];
	chars[charNum] = '\0';
	
	// establish set
	CSet*		words = _words.cs;
	CSet*		black = blackList ? blackList.cs : NULL;
	
	// check if has joker(s), collect offsets
	int			jokers = 0;
	int*		jokersOfs = alloca(sizeof(int) * charNum);
	unichar		jokerChar = [JokerUtils jokerCharacter];
	for ( int ofs = 0 ; ofs < charNum ; ofs++ )
		if ( chars[ofs] == jokerChar )
			jokersOfs[jokers++] = ofs;
	
	// no jokers, easy
	if ( !jokers )
	{
		int			index = CSet_MemberIndex(words, (T_ELEM)chars, 0, words->size);
		if ( index < 0 )
			return NULL;
		else
		{
			NSString*		word = [self getWordByIndex:index];
			
			if ( [whiteListWords count] && ![whiteListWords containsObject:word] )
				return NULL;
			
			return [self getWordByIndex:index];
		}
	}
	
	// check if not too many jokers
	if ( jokers > [JokerUtils maxJokersInWord] )
		return NULL;
	
	// get symbols of the alphabet
	int			symbolNum = [_alphabet size];
	unichar*	symbols = [_alphabet allSymbols:AlphabetSymbolOrderRandom];
	
	// figure out how many combinations, lay them out on a linear scale
	int			combinationNum = symbolNum;
	for ( int n = 1 ; n < jokers ; n++)
		combinationNum *= combinationNum;
	
	// walk the combinations and test them out
	for ( int combination = 0 ; combination < combinationNum ; combination++ )
	{
		// install chars
		int		temp = combination;
		for ( int jokerIndex = 0 ; jokerIndex < jokers ; jokerIndex++ )
		{
			int		charIndex = (temp % symbolNum);
			temp /= symbolNum;
			int		ofs = jokersOfs[jokerIndex];
			
			chars[ofs] = symbols[charIndex];
		}
		
		// check if word is valid
		int			index = CSet_MemberIndex(words, (T_ELEM)chars, 0, words->size);
		if ( index >= 0 )
		{
			// check if not on backlist
			if ( black && CSet_IsMember(black, index) )
				continue;
			
			NSString*	word = [self getWordByIndex:index];
			if ( [whiteListWords count] && ![whiteListWords containsObject:word] )
				continue;
			
			// return the word
			return [self getWordByIndex:index];
		}
	}

	// if here, did not find any word
	return NULL;
}

-(CSetWrapper*)getValidWordSet:(const unichar*)chars withCharsNum:(int)charsNum 
			   withMinWordSize:(int)minWordSize 
			   withMaxWordSize:(int)maxWordSize 
				  andBlackList:(CSetWrapper*)blackList
{
#ifdef MEASURE
	// HACK!!
	startedAt = clock();
#endif
	
#ifdef	MEASURE
	NSLog(@"[StringsLanguage] %f started", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif		
	
	
	// allocate and init
	int			symbolsCount = [_alphabet size];
	CSet**		csNegativeVector = alloca((symbolsCount + 1) * sizeof(CSet*));
	CSet*		allWordsCS = _allWordsSet.cs;
	
	// initialize negative sets
	for ( int setIndex = 0 ; setIndex < symbolsCount ; setIndex++ )
		if ( setIndex < [_wordSymbolsSets count] )
		{
			CSetWrapper*	csw1 = [_wordSymbolsSets objectAtIndex:setIndex];
			
			csNegativeVector[setIndex] = csw1 ? [csw1 invertedCS:allWordsCS] : allWordsCS;
		}
	
#ifdef	MEASURE
	NSLog(@"[StringsLanguage] %f init negatives", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
	
	// order symbols within word by sorting order to get repeating symbols to be consecutive
	unichar*			groupedChars = alloca((charsNum + 1) * sizeof(unichar));
	[self groupChars:chars withCharsNum:charsNum into:groupedChars];
	
	// scan sorted symbols, unify repeating symbols
	int			repeatCount = 0;
	unichar		lastChar = 0;
	for ( int charIndex = 0 ; charIndex < charsNum ; )
	{
		unichar			ch = groupedChars[charIndex++];
		
		// about to change?
		if ( charIndex >= charsNum || groupedChars[charIndex] != ch )
		{
			// update negative set
			int				symbolIndex = [_alphabet symbolIndex:ch];
			if ( symbolIndex >= 0 )
			{
				int				setIndex = symbolIndex + (repeatCount +	1) * symbolsCount;
				CSetWrapper*	csw1 = NULL;
				if ( setIndex < [_wordSymbolsSets count] )
					csw1 = [_wordSymbolsSets objectAtIndex:setIndex];
				csNegativeVector[setIndex % symbolsCount] = csw1 ? [csw1 invertedCS:allWordsCS] : allWordsCS;
			}
			
			// reset repeat count
			repeatCount = 0;
		}
		else
			repeatCount++;
		
		// move to next
		lastChar = ch;
	}
	
#ifdef	MEASURE
	NSLog(@"[StringsLanguage] %f collected chars", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
	// intersect, starting with either all or a subst effected by min/max size
	csNegativeVector[symbolsCount] = [self getMinMaxWordsCS:minWordSize withMaxWordSize:maxWordSize];
	CSet*		result = CSet_Intersect(csNegativeVector, symbolsCount + 1, NULL);

#ifdef	MEASURE
	NSLog(@"[StringsLanguage] %f intersected", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
	if ( blackList && blackList.cs->size )
	{
		CSet*		blackListCS = blackList.cs;
		
		CSet_NegativeIntersect(result, &blackListCS, 1, result);
	}
	
#ifdef	MEASURE
	NSLog(@"[StringsLanguage] %f done", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
	
		
	return [[[CSetWrapper alloc] initWithCSet:result] autorelease];
	
}	

int 
compare_unichars(const void * a, const void * b)
{
	return ( *(unichar*)a - *(unichar*)b );
}


-(void)groupChars:(const unichar*)chars withCharsNum:(int)charsNum into:(unichar*)groupedChars
{
	// handling of some easy and common cases to speed things up
	switch ( charsNum )
	{
		case 0 :
			// no chars ... easy
			break;
			
		case 1 :
			// 1 char - no grouping required
			groupedChars[0] = chars[0];
			break;
			
		case 2 :
			// 2 chars - already groupped (think about it ...)
			groupedChars[0] = chars[0];
			groupedChars[1] = chars[1];
			break;

		case 3 :
			// 3 chars - last character determines grouping ... only if it is like the first one - we need to regroup
			groupedChars[0] = chars[0];
			if ( chars[2] != chars[0] )
			{
				groupedChars[1] = chars[1];
				groupedChars[2] = chars[2];
			}
			else
			{
				groupedChars[1] = chars[2];
				groupedChars[2] = chars[2];
			}
			break;
			
		case 4 :
			// 4 chars - like 3, but a bit more complicated
			groupedChars[0] = chars[0];
			if ( chars[2] != chars[0] )
			{
				groupedChars[1] = chars[1];
				groupedChars[2] = chars[2];
			}
			else
			{
				groupedChars[1] = chars[2];
				groupedChars[2] = chars[1];
			}
			
			// push 4'th in
			if ( chars[3] == groupedChars[0] )
			{
				groupedChars[3] = groupedChars[2];
				groupedChars[2] = groupedChars[1];
				groupedChars[1] = chars[3];
			}
			else if ( chars[3] == groupedChars[1] )
			{
				groupedChars[3] = groupedChars[2];
				groupedChars[2] = chars[3];
			}
			else
				groupedChars[3] = chars[3];
			break;
			
			
			
		default :
			memcpy(groupedChars, chars, charsNum * sizeof(unichar));
			qsort(groupedChars, charsNum, sizeof(unichar), compare_unichars);
			break;
	}
}

-(unichar)getValidWordCharacterByIndex:(int)index characterAt:(int)charIndex
{
	unichar*		chars = (unichar*)_words.cs->elems[index];

	return chars[charIndex];
}

-(NSString*)getWordByIndex:(int)index
{
	if ( index > _words.cs->size )
		return @"";
	unichar*		chars = (unichar*)_words.cs->elems[index];
	if ( !chars )
		return @"";
	int				charNum = unichar_strlen(chars);
	
	return [NSString stringWithCharacters:chars length:charNum];
}

-(NSString*)getValidWordByIndex:(int)index
{
	return [self getWordByIndex:index];
}

-(NSArray*)getAllWords
{
	// HACK
	if ( _allWordsOverride )
		return _allWordsOverride;
	
	if ( !_jitAllWords )
	{
		// NOTE: this is expensive for large languages but essential for smaller ones ...
		self.jitAllWords = [[[NSMutableArray alloc] init] autorelease];
		
		CSet*		words = _words.cs;
		for ( int wordIndex = 0 ; wordIndex < words->size ; wordIndex++ )
		{
			unichar*	chars = (unichar*)words->elems[wordIndex];
			int			charNum = unichar_strlen(chars);
			
			[_jitAllWords addObject:[NSString stringWithCharacters:chars length:charNum]];
		}
	}
	return _jitAllWords;
}

-(NSURL*)wordSoundUrl:(NSString*)word
{
	// no uuid, no sound
	if ( !_uuid )
		return NULL;
	
	// load sound by name
	NSString*	soundWord;
	NSArray*	originalWords = [_wordsOrigin objectForKey:word];
	if ( !originalWords )
		soundWord = word;
	else
	{
		int			index = rand() % [originalWords count];
		
		soundWord = [originalWords objectAtIndex:index];
	}
	NSString*	soundPath = [[self uuidFolder] 
							 stringByAppendingPathComponent:[NSString stringWithFormat:@"/sounds/%@.mp3", soundWord]];
	
	if ( ![[NSFileManager defaultManager] fileExistsAtPath:soundPath] )
	{
		// fallback on props?
		NSString*		pathComponent = [[[_props objectForKey:@"words"] objectForKey:soundWord] objectForKey:@"sound"];
		if ( pathComponent )
		{
			soundPath = [_uuidFolder stringByAppendingPathComponent:pathComponent];
		}

		if ( ![[NSFileManager defaultManager] fileExistsAtPath:soundPath] )
			return NULL;
	}
	
	return [[[NSURL alloc] initFileURLWithPath:soundPath] autorelease];
}

-(UIImage*)wordImage:(NSString*)word
{
	if ( !word )
		return NULL;
	
	id<NSObject>	imageSpec = [_wordImages objectForKey:word];
	if ( imageSpec )
	{
		if ( [imageSpec isKindOfClass:objc_getClass("NSURL")] )
		{
			NSURL*		url = (NSURL*)imageSpec;
			NSData*		data = [NSData dataWithContentsOfURL:url];
			UIImage*	image = [[[ImageWithUUID alloc] initWithData:data] autorelease];
			((ImageWithUUID*)image).uuid = [UUIDUtils createUUID];
			
			[_wordImages setObject:image forKey:word];
			
			return image;
		}
		else if ( [imageSpec isKindOfClass:objc_getClass("NSString")] )
		{
			NSString*	imagePath = [[self uuidFolder] 
									 stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@.jpg", imageSpec]];
			//NSLog(@"[StringsLanguage] imagePath: %@", imagePath);
			UIImage*	image = [[[ImageWithUUID alloc] initWithContentsOfFile:imagePath] autorelease];
			((ImageWithUUID*)image).uuid = [UUIDUtils createUUID];
			
			if ( image )
				[_wordImages setObject:image forKey:word];
			
			return image;
		}
		else if ( [imageSpec isKindOfClass:objc_getClass("UIImage")] )
			return imageSpec;
		else
			return NULL;
		
	}
	
	// no uuid, no image
	if ( !_uuid )
		return NULL;
	
	// load image by name
	NSString*	imageWord;
	NSArray*	originalWords = [_wordsOrigin objectForKey:word];
	if ( !originalWords )
		imageWord = word;
	else
	{
		int			index = rand() % [originalWords count];
		
		imageWord = [originalWords objectAtIndex:index];
	}
	NSString*	imagePath = [[self uuidFolder] 
							 stringByAppendingPathComponent:[NSString stringWithFormat:@"/images/%@.jpg", imageWord]];
	//NSLog(@"[StringsLanguage] imagePath: %@", imagePath);
	UIImage*	image = [[[ImageWithUUID alloc] initWithContentsOfFile:imagePath] autorelease];
	((ImageWithUUID*)image).uuid = [UUIDUtils createUUID];	
	
	// fallback on props?
	if ( !image )
	{
		NSString*		pathComponent = [[[_props objectForKey:@"words"] objectForKey:imageWord] objectForKey:@"image"];
		if ( pathComponent )
		{
			imagePath = [_uuidFolder stringByAppendingPathComponent:pathComponent];
			
			image = [[[ImageWithUUID alloc] initWithContentsOfFile:imagePath] autorelease];
			((ImageWithUUID*)image).uuid = [UUIDUtils createUUID];
		}
	}
	
	if ( image )
		[_wordImages setObject:image forKey:word];
	else
		[_wordImages setObject:[NSNull null] forKey:word];
	
	return image;	
}

-(UIImage*)symbolImage:(unichar)symbol
{
	if ( symbol == NO_SYMBOL )
		return NULL;
	
	NSString*		word = [NSString stringWithCharacters:&symbol length:1];
	id<NSObject>	imageSpec = [_symbolImages objectForKey:word];
	if ( imageSpec )
	{
		if ( [imageSpec isKindOfClass:objc_getClass("UIImage")] )
			return imageSpec;
		else if ( [imageSpec isKindOfClass:[NSArray class]] )
		{
			NSArray*	array = (NSArray*)imageSpec;
			int			index = rand() % [array count];
			
			return [array objectAtIndex:index];
		}
		else
			return NULL;
	}
	
	// no uuid, no image
	if ( !_uuid )
		return NULL;
	
	UIImage*		image = NULL;
	
	// has prop?
	[self loadProps];
	NSString*		key = [NSString stringWithFormat:@"skin/images/symbols_%@", word];
	id				value = [_props objectForKey:key withDefaultValue:nil];
	if ( [value isKindOfClass:[NSString class]] )
		value = [NSArray arrayWithObject:value];
	if ( value )
	{
		NSMutableArray*		images = [NSMutableArray array];
		for ( NSString* path in (NSArray*)value )
		{
			// load image
			NSString*	imagePath = [[self uuidFolder] stringByAppendingPathComponent:path];
			//NSLog(@"[StringsLanguage] imagePath: %@", imagePath);
			image = [[[ImageWithUUID alloc] initWithContentsOfFile:imagePath] autorelease];
			((ImageWithUUID*)image).uuid = [UUIDUtils createUUID];

			if ( image )
				[images addObject:image];
		}
		
		if ( [images count] )
		{
			[_symbolImages setObject:images forKey:word];	
			return [self symbolImage:symbol];
		}
	}
	
	// if here, fail
	[_symbolImages setObject:[NSNull null] forKey:word];
	return NULL;
}

-(BOOL)showSymbolTextOnSymbolImage
{
	// look in prefs
	NSString*		key = @"skin/props/show-symbol-text";
	NSNumber*		v = [UserPrefs getObject:[NSString stringWithFormat:@"%@/%@", _uuid, key] withDefault:NULL];
	if ( v )
		return [v boolValue];
	
	// otherwise, look in props
	[self loadProps];
	return [_props booleanForKey:key withDefaultValue:TRUE];
	
}

-(NSObject*)getSkinProp:(NSString*)name withDefaultValue:(NSObject*)defaultValue
{
	// look in prefs
	NSString*		key = [NSString stringWithFormat:@"skin/props/%@", name];
	NSObject*		v = [UserPrefs getObject:[NSString stringWithFormat:@"%@/%@", _uuid, key] withDefault:NULL];
	if ( v )
		return v;

	// otherwise, look in props
	[self loadProps];
	return [_props objectForKey:key withDefaultValue:defaultValue];
}


-(void)wordDispensed:(NSString*)word
{
	
}

-(void)wordCompleted:(NSString*)word
{
	
}

-(NSString*)wordForHintWord:(NSString*)word
{
	return word;
}

-(void)addWord:(NSString*)word
{
	// this is currently out of scope
#ifdef DUMP
	NSLog(@"StringsLanguage: addWord=%@", word);
#endif
	if ( _uuid )
	{
		NSArray*		emptyArray = [NSArray array];
		NSMutableArray*	whiteList = [NSMutableArray arrayWithArray:[UserPrefs getArray:[UserPrefs key:PK_LANG_WHITELIST forUuid:_uuid] withDefault:emptyArray]];
		
		if ( ![whiteList containsObject:word] )
			[whiteList addObject:word];
		
		[UserPrefs setArray:[UserPrefs key:PK_LANG_WHITELIST forUuid:_uuid] withValue:whiteList];
	}
}

-(int)wordCount
{
	return _words.cs->size;
}

-(void)addWordImage:(id<NSObject>)imageSpec toWord:(NSString*)word
{
	[_wordImages setObject:imageSpec forKey:word];
}

-(int)wordIndex:(NSString*)word
{
	// move into chars
	unichar*			chars = alloca((_wordLengthMax + 1) * sizeof(unichar));
	int					charNum = [word length];
	[word getCharacters:chars];
	chars[charNum] = '\0';

	// lookup
	CSet*				words = _words.cs;
	int					index = CSet_MemberIndex(words, (T_ELEM)chars, 0, words->size);
	
	return index;
}

-(NSString*)uuidFolder
{
	if ( !_uuidFolder )
	{
		_uuidFolder = [[Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:self.uuid] retain];
		if ( !_uuidFolder )
			_uuidFolder = [[Folders temporaryFolder] retain];
	}
	
	return _uuidFolder;
}

-(NSString*)stringFromWordArray:(NSArray*)array withPrefix:(NSString*)prefix andSuffix:(NSString*)suffix
{
	NSMutableString*		string = [[[NSMutableString alloc] init] autorelease];
	
	if ( prefix )
		[string appendString:prefix];
	
	for ( NSString* word in array )
	{
		[string appendString:word];
		[string appendString:@"\n"];
	}
	
	if ( suffix )
		[string appendString:suffix];
	
	return string;
}

-(NSString*)getRandomWord:(int)minSize withMaxSize:(int)maxSize withBlackList:(CSetWrapper*)blackList;
{
	// establish defaults
	if ( minSize <= 0 )
		minSize = 1;
	if ( maxSize <= 0 )
		maxSize = [_wordLengthSets count] - 1;
	else
		maxSize = MIN(maxSize, [_wordLengthSets count] - 1);
	
	// get set
	CSet*		cs = [self getMinMaxWordsCS:minSize withMaxWordSize:maxSize];
	CSet*		words = cs;
	CSet_SortElements(cs);
	//CSet_NSLogWithElementsNames(cs, [self getAllWords], @"cs:");
	
	// remove blackList
	if ( blackList && blackList.cs->size )
	{
		CSet*		blackListCS = blackList.cs;
		
		CSet_SortElements(blackListCS);
		//CSet_NSLogWithElementsNames(blackListCS, [self getAllWords], @"blackListCS:");

		words = CSet_NegativeIntersect(cs, &blackListCS, 1, NULL);
	}
	
	CSet_SortElements(words);
	//CSet_NSLogWithElementsNames(words, [self getAllWords], @"words:");
	
	NSString*	word = NULL;
	if ( words->size )
	{
		// get a random index into set
		int			index = rand() % words->size;
	
		word = [self getWordByIndex:words->elems[index]];
	}
	
	if ( words != cs )
		CSet_Free(words);
	
	return word;
}

-(int)getWordCount:(int)minSize withMaxSize:(int)maxSize
{
	// establish defaults
	if ( minSize <= 0 )
		minSize = 1;
	if ( maxSize <= 0 )
		maxSize = [_wordLengthSets count] - 1;
	else
		maxSize = MIN(maxSize, [_wordLengthSets count] - 1);
	
	// sum sizes
	int			sum = 0;
	for ( int size = minSize ; size <= maxSize ; size++ )
	{
		CSetWrapper*	wrapper = [_wordLengthSets objectAtIndex:size];
		
		sum += wrapper.cs->size;
	} 
	
	return sum;
}



-(CSet*)getMinMaxWordsCS:(int)minWordSize withMaxWordSize:(int)maxWordSize
{
	// no limits?
	if ( minWordSize <= 0 && maxWordSize <= 0 )
		return _allWordsSet.cs;
	
	// enforce some min and max
	minWordSize = MAX(1, minWordSize);
	if ( maxWordSize <= 0 || maxWordSize >= [_wordLengthSets count] )
		maxWordSize = [_wordLengthSets count] - 1;
	
	// check if not already computed
	NSNumber*		key = [NSNumber numberWithInt:(minWordSize * 100 + maxWordSize)];
	CSetWrapper*	w;
	@synchronized (self)
	{
		if ( !_minMaxWordSets )
			self.minMaxWordSets = [[[NSMutableDictionary alloc] init] autorelease];
		w = [_minMaxWordSets objectForKey:key];
		if ( !w )
		{
			CSet*		result = CSet_Alloc(0x100);
			
			for ( int size = minWordSize ; size <= maxWordSize ; size++ )
			{
				CSet*		cs = ((CSetWrapper*)[_wordLengthSets objectAtIndex:size]).cs;
			
				CSet_AddAllElements(result, cs);
			}
			w = [[[CSetWrapper alloc] initWithCSet:result] autorelease];
			
			[_minMaxWordSets setObject:w forKey:key];
		}
	}
	return w.cs;
}

-(void)loadProps
{
	if ( _props )
		return;
	
	@synchronized (self)
	{
		if ( !_uuidFolder )
			self.uuidFolder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:_uuid];
		self.props = [Folders getMutableFolderProps:_uuidFolder];
	}
}

-(int)maxWordSize
{
	return _wordLengthMax;
}

-(NSDictionary*)wordMetaData:(NSString*)word
{
	int						index = [self wordIndex:word];
	if ( index < 0 )
		return NULL;
	
	NSMutableDictionary*	dict = [NSMutableDictionary dictionary];
	
	// word
	[dict setObject:word forKey:WMD_WORD];
	NSString*		originWord = word;
	if ( [_wordsOrigin hasKey:word] )
	{
		NSArray*		words = [_wordsOrigin objectForKey:word];
		if ( [words count] )
		{
			originWord = [words objectAtIndex:(rand() % [words count])];
			
			[dict setObject:originWord forKey:WMD_WORD_ORIGIN];
		}
	}
	
	// image
	UIImage*		image = [self wordImage:word];
	if ( image )
		[dict setObject:image forKey:WMD_IMAGE];
	
	// text
	if ( _texts && [_texts hasKey:originWord] )
		[dict setObject:[_texts objectForKey:originWord] forKey:WMD_TEXT];
	if ( _titles && [_titles hasKey:originWord] )
		[dict setObject:[_titles objectForKey:originWord] forKey:WMD_TEXT_TITLE];
	
	// props
	NSDictionary*	props = [[_props objectForKey:@"words"] objectForKey:originWord];
	if ( props )
		[dict setObject:props forKey:@"props"];
	else
		[dict setObject:[NSDictionary dictionary] forKey:@"props"];
	
	return dict;
}

@end
