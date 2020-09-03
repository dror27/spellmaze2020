//
//  SymbolAlphabet.h
//  Board3
//
//  Created by Dror Kessler on 5/11/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alphabet.h"

@interface SymbolAlphabet : NSObject<Alphabet> {

	NSMutableArray*		_symbols;
	int					countSum;
	
	unichar*			_allSymbols;
}
@property (retain) NSMutableArray* symbols;

-(void)addSymbol:(unichar)symbol withCount:(int)count;

@end
