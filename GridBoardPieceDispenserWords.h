//
//  GridBoardPieceDispenserWords.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridBoardPieceDispenserBase.h"
#import "WordDispenser.h"

@interface GridBoardPieceDispenserWords : GridBoardPieceDispenserBase {

	id<WordDispenser>		_wordDispenser;
	
	NSString*				_currentWord;
	int						currentIndex;
	int						currentWordId;
	
	int*					_dispensingOrder;
	
	float					interWordTickPeriod;
	BOOL					scrambleWordSymbols;
}
@property (retain) id<WordDispenser> wordDispenser;
@property (retain) NSString* currentWord;
@property float interWordTickPeriod;
@property BOOL scrambleWordSymbols;

// private
-(NSString*)scramble:(NSString*)word;
-(void)buildDispensingOrder;

@end
