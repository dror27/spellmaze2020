//
//  StringsLanguage.h
//  Board3
//
//  Created by Dror Kessler on 5/9/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Language.h"
#import "SymbolAlphabet.h"
#import "CSet.h"

@interface StringsLanguage : NSObject<Language> {

	NSString*				_uuid;
	NSString*				_uuidFolder;
	NSDictionary*			_props;
	
	id<Alphabet>			_alphabet;			// the symbols that make up words in the language
	
	CSetWrapper*			_words;				// the words set
	int						_wordLengthMax;		// the length of the longest word

	NSMutableArray*			_wordSymbolsSets;	// the sets for words that use symbols (value=CSetWrapper)
	NSMutableArray*			_wordLengthSets;		// set sets for words of a specific length (value=CSetWrapper)
	NSMutableDictionary*	_wordImages;		// image information for the words (key=word, value=word/path/UIImage/etc)
	NSMutableDictionary*	_symbolImages;		// image information for the symbols (key=word, value=word/path/UIImage/etc)
	NSMutableDictionary*	_wordsOrigin;		// origin of (split?) words
	
	CSetWrapper*			_allWordsSet;		// a set of all the word indexes
	
	NSString*				_filePath;			// path to words.txt file (incase loaded from a file)
	
	BOOL					_allValid;
	BOOL					_rtl;
	int						_minWordLength;
	
	BOOL					_splitWords;
	BOOL					_allCaps;
	NSString*				_textDelimiter;
	
	BOOL					_allowAddWord;
	
	NSMutableArray*			_jitAllWords;			// this is created jit
	
	NSMutableDictionary*	_minMaxWordSets;			// sets of words with min/max size (cache)
	
	NSArray*				_allWordsOverride;
	
	unichar*				_buf;				// the words strings storage buffer
	NSMutableDictionary*	_texts;				// texts for words
	NSMutableDictionary*	_titles;			// titles for words
	
	NSString*				_name;
	NSString*				_voiceLanguage;
}
@property (retain) NSString* uuid;
@property BOOL allValid;
@property BOOL rtl;
@property int minWordLength;
@property BOOL splitWords;
@property BOOL allCaps;
@property BOOL allowAddWord;
@property (retain) NSString* textDelimiter;
@property (retain) NSArray* allWordsOverride;

@property (retain) NSMutableDictionary* texts;
@property (retain) NSMutableDictionary* titles;


/* Privates */
@property (retain) NSString* uuidFolder;
@property (retain) NSDictionary* props;
@property (retain) id<Alphabet> alphabet;
@property (retain) CSetWrapper*	words;
@property int wordLengthMax;
@property (retain) NSMutableArray* wordSymbolsSets;
@property (retain) NSMutableArray* wordLengthSets;
@property (retain) NSMutableDictionary*	wordImages;
@property (retain) NSMutableDictionary*	symbolImages;
@property (retain) NSMutableDictionary*	wordsOrigin;
@property (retain) CSetWrapper*	allWordsSet;
@property (retain) NSString* filePath;
@property (retain) NSMutableArray* jitAllWords;
@property (retain) NSMutableDictionary*	minMaxWordSets;

@property (retain) NSString* name;
@property (retain) NSString* voiceLanguage;


-(id)initWithStringsFile:(NSString*)path;
-(id)initWithStringsArray:(NSArray*)array;
-(id)initWithStringsString:(NSString*)strings;



@end
