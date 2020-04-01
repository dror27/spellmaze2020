//
//  RandomSymbolDispenser.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SymbolDispenser.h"
#import "Alphabet.h"

@interface RandomSymbolDispenser : NSObject<SymbolDispenser> {

	id<Alphabet>	_alphabet;
	int				symbolsLeft;
	int				symbolCount;
	
	NSMutableString* _rushSymbols;
}
@property (retain) id<Alphabet> alphabet;
@property (retain) NSMutableString* rushSymbols;
@property int symbolCount;

@end
