//
//  SymbolForWordLanguage.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/10/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Language.h"

@class SymbolAlphabet;
@interface SymbolForWordLanguage : NSObject<Language> {

	id<Language>			_base;
	SymbolAlphabet*			_alphabet;
	NSArray*				_allWords;
	NSMutableDictionary*	_wordsOrigin;
	
	int				wordCount;
}
-(id)initWithBaseLanguage:(id<Language>)base;

@property (retain) id<Language>			base;
@property (retain) id<Alphabet>			alphabet;
@property (retain) NSArray*				allWords;
@property (retain) NSMutableDictionary*	wordsOrigin;

@end
