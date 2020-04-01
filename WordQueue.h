//
//  WordQueue.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSet.h"
#import "Language.h"
#import "CSetWrapper.h"


@interface WordQueue : NSObject {

	CSet*			_wordsCS;
	NSMutableArray*	_prepWords;
	id<Language>	_language;
}
@property (retain) NSMutableArray* prepWords;
@property (retain) id<Language> language;


-(id)initWithLanguageWords:(id<Language>)language withMinSize:(int)minSize andMaxSize:(int)maxSize andBlackList:(CSetWrapper*)blackList;
-(BOOL)hasWords;
-(NSString*)nextWord;

@end
