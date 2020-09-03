//
//  WordListWordDispenser.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WordDispenser.h"

@interface WordListWordDispenser : NSObject<WordDispenser> {

	NSArray*			_words;
	int					dispenseIndex;
	
}
@property (retain) NSArray* words;

-(id)initWithWords:(NSArray*)initWords;
-(id)initWithWords:(NSArray*)initWords andRandomOrder:(BOOL)randomOrder;


@end
