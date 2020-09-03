//
//  Language.h
//  Board3
//
//  Created by Dror Kessler on 4/30/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

#import "Alphabet.h"
#import "WordValidator.h"
#import "CSet.h"

@class CSetWrapper;

@protocol Language <WordValidator,NSObject> 

-(NSString*)name;

-(NSString*)uuid;
-(NSString*)uuidFolder;

-(id<Alphabet>)alphabet;
-(NSString*)getWordByIndex:(int)index;
-(NSArray*)getAllWords;
-(int)wordCount;
-(int)wordIndex:(NSString*)word;

-(BOOL)rtl;

-(UIImage*)wordImage:(NSString*)word;
-(UIImage*)symbolImage:(unichar)symbol;
-(BOOL)showSymbolTextOnSymbolImage;

-(NSURL*)wordSoundUrl:(NSString*)word;

-(BOOL)allowAddWord;
-(void)addWord:(NSString*)word;
-(void)addWordImage:(id<NSObject>)imageSpec toWord:(NSString*)word;

-(NSString*)getRandomWord:(int)minSize withMaxSize:(int)maxSize withBlackList:(CSetWrapper*)blackList;
-(int)getWordCount:(int)minSize withMaxSize:(int)maxSize;

-(NSMutableDictionary*)wordsOrigin;

-(int)maxWordSize;

-(NSString*)voiceLanguage;

-(NSDictionary*)props;

-(NSDictionary*)wordMetaData:(NSString*)word;

-(CSet*)getMinMaxWordsCS:(int)minWordSize withMaxWordSize:(int)maxWordSize;

// Word Meta Data
#define			WMD_INDEX		@"index"
#define			WMD_WORD		@"word"
#define			WMD_WORD_ORIGIN	@"word-origin"
#define			WMD_IMAGE		@"image"
#define			WMD_TEXT		@"text"
#define			WMD_TEXT_TITLE	@"text-title"
#define			WMD_PROPS		@"props"

#define			WMD_PROPS_SPLASH_TEXT_FONT_SIZE	@"splash-text-font-size"

@end
