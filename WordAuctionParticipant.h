//
//  WordAuctionParticipant.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/22/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuctionParticipant.h"


@interface WordAuctionParticipant : NSObject<AuctionParticipant> {

	NSString*		_word;
	unichar*		_symbols;
	int				symbolCount;
	unichar			leadingSymbol;
	
	int				wordIndex;
	BOOL			blackListed;
	int				blackListVersion;
}

-(id)initWithWord:(NSString*)word andWordIndex:(int)wordIndex;
@end
