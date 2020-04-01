//
//  PerfAllPurchaseRecordsSection.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefSection.h"


@interface PrefPurchaseRecordsSection : PrefSection {
	
	int		stateMask;
}
@property int stateMask;

@end
