/*
 *  BoardPotentialFunction.h
 *  Board3
 *
 *  Created by Dror Kessler on 7/16/09.
 *  Copyright 2020 Dror Kessler (M). All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import "Board.h"
#import "Language.h"

@class BPF_Entry;
@class CSetWrapper;
@protocol BoardPotentialFunction <NSObject>

// returns array of BPF_Entry, sorted on descending score
-(NSArray*)potentialsFor:(NSString*)boardSymbols withSymbolFromLanguage:(id<Language>)language 
		 withPrefixEntry:(BPF_Entry*)prefixEntry withMinSize:(int)minSize andBlackList:(CSetWrapper*)blackList;

@end




