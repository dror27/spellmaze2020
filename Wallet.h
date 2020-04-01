//
//  Wallet.h
//  Board3
//
//  Created by Dror Kessler on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Language.h"

@interface Wallet : NSObject {

	NSMutableDictionary*	_items;
	NSDictionary*			_stepSizes;
	int						version;
	NSMutableSet*			_hintBlackWords;
	
}
@property (retain) NSMutableDictionary* items;
@property (retain) NSDictionary* stepSizes;
@property (readonly) int version;
@property (retain) NSMutableSet* hintBlackWords;

+(Wallet*)singleton;

-(BOOL)incrWalletItemValue:(NSString*)itemName incr:(int)incr;
-(int)walletItemValue:(NSString*)itemName;
-(int)walletItemDisplayStepSize:(NSString*)itemName;
-(NSArray*)allWalletItems;

-(BOOL)hasSteppedWalletItem:(NSString*)itemName;
-(BOOL)incrWalletItemValueByStep:(NSString*)itemName incr:(int)incr;

-(void)addHintBlackWord:(NSString*)word;
-(void)clearHintBlackWords;
-(NSSet*)allHintBlackWords;
-(void)checkNotAllLanguageWordsHintBlackWords:(id<Language>)language;
@end
