//
//  WordListWordDispenser.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "WordListWordDispenser.h"
#import "NSMutableArray_Shuffle.h"


@implementation WordListWordDispenser
@synthesize words = _words;

-(void)dealloc
{
	[_words release];
	
	[super dealloc];
}

-(id)initWithWords:(NSArray*)initWords
{
	return [self initWithWords:initWords andRandomOrder:FALSE];
}

-(id)initWithWords:(NSArray*)initWords andRandomOrder:(BOOL)randomOrder
{
	if ( self = [super init] )
	{
		if ( !randomOrder )
			self.words = initWords;
		else
		{
			NSMutableArray*		words = [NSMutableArray arrayWithArray:initWords];
			
			[words shuffle];
			self.words = words;
		}
		dispenseIndex = 0;
	}
	return self;
}

-(NSString*)dispense
{
	if ( dispenseIndex < [_words count] )
	{
		NSString*	word = [_words objectAtIndex:dispenseIndex++];
		
		return word;
	}
	else
		return NULL;
}

-(BOOL)canDispense
{
	return dispenseIndex < [_words count];
}

-(float)progress
{
	if ( [_words count] )
		return (float)dispenseIndex / [_words count];
	else
		return 0;
}


@end
