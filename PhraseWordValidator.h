//
//  PhraseWordValidator.h
//  Board3
//
//  Created by Dror Kessler on 7/20/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WordValidator.h"

@interface PhraseWordValidator : NSObject<WordValidator> {

	NSString*			_phrase;
	NSArray*			_words;
	int					currentWordIndex;
}
@property (retain) NSString* phrase;
@property (retain) NSArray* words;

@end
