//
//  Wallet.m
//  Board3
//
//  Created by Dror Kessler on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Wallet.h"
#import "Piece.h"
#import "SystemUtils.h"

extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"Wallet_singleton"


@implementation Wallet
@synthesize items = _items;
@synthesize stepSizes = _stepSizes;
@synthesize version = version;
@synthesize hintBlackWords = _hintBlackWords;


+(Wallet*)singleton
{
	@synchronized ([Wallet class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[Wallet alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(id)init
{
	if ( self = [super init] )
	{
		self.items = [[[NSMutableDictionary alloc] init] autorelease];
		
		self.stepSizes = [NSDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithInt:21], DECORATOR_APPLE,
												[NSNumber numberWithInt:18], DECORATOR_COIN,
												[NSNumber numberWithInt:16], DECORATOR_BOMB,
						  NULL];
		
		self.hintBlackWords = [NSMutableSet set];
	}
	return self;
}

-(void)dealloc
{
	[_items release];
	[_stepSizes release];
	
	[super dealloc];
}

-(BOOL)incrWalletItemValue:(NSString*)itemName incr:(int)incr
{
	// increment upwards only if not in autorun mode...
	if ( incr > 0 )
	{
		if ( [SystemUtils autorun] && ![SystemUtils autorunAccumulateScore] )
			return FALSE;
	}
	
	int			value = [self walletItemValue:itemName];
	int			stepSize = [self walletItemDisplayStepSize:itemName];
	BOOL		stepChanged = (value / stepSize) != ((value + incr) / stepSize);
	
	value += incr;
	
	if ( value )
		[_items setObject:[NSNumber numberWithInt:value] forKey:itemName];
	else
		[_items removeObjectForKey:itemName];
	
	version++;
	
	return stepChanged;
}

-(int)walletItemValue:(NSString*)itemName
{
	NSNumber*	value = [_items objectForKey:itemName];
	
	return value ? [value intValue] : 0;
}

-(NSArray*)allWalletItems
{
	return [_items allKeys];
}

-(int)walletItemDisplayStepSize:(NSString*)itemName
{
	NSNumber*		stepSize = [_stepSizes objectForKey:itemName];
	
	return stepSize ? [stepSize intValue] : 1;
}

-(BOOL)hasSteppedWalletItem:(NSString*)itemName
{
	int			step = [self walletItemDisplayStepSize:itemName];
	int			value = [self walletItemValue:itemName];
	
	return value >= step;
}

-(BOOL)incrWalletItemValueByStep:(NSString*)itemName incr:(int)incr
{
	return [self incrWalletItemValue:itemName incr:incr * [self walletItemDisplayStepSize:itemName]];
}

-(void)addHintBlackWord:(NSString*)word
{
	[_hintBlackWords addObject:word];
}

-(void)clearHintBlackWords
{
	[_hintBlackWords removeAllObjects];
}

-(NSSet*)allHintBlackWords
{
	return _hintBlackWords;
}

-(void)checkNotAllLanguageWordsHintBlackWords:(id<Language>)language
{
	// if has # of words less then the language, ok
	if ( [_hintBlackWords count] < [language wordCount] )
		return;
	
	// loop on words, accumulate words from the language
	NSMutableSet*	words = [NSMutableSet set];
	for ( NSString* word in _hintBlackWords )
		if ( [language wordIndex:word] >= 0 )
			[words addObject:word];
	
	// if number of accumulated words is same (or larger?) of words in language, clean them out
	if ( [words count] >= [language wordCount] )
		for ( NSString* word in words )
			[_hintBlackWords removeObject:word];
}

@end
