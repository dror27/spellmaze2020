//
//  Alphabet.h
//  Board3
//
//  Created by Dror Kessler on 4/30/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#define		NO_SYMBOL		0xFFFF

typedef enum
{
	AlphabetSymbolOrderNatural,
	AlphabetSymbolOrderWeights,
	AlphabetSymbolOrderRandom
} AlphabetSymbolOrder;

@protocol Alphabet <NSObject>

-(int)size;
-(unichar)symbolAt:(int)index;
-(float)weightAt:(int)index;
-(int)symbolIndex:(unichar)symbol;
-(unichar*)allSymbols:(AlphabetSymbolOrder)order;

@end
