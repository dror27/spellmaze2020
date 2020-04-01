//
//  PrefCheckForUpdatesActionItem.h
//  SpellMaze
//
//  Created by Dror Kessler on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefThreadedActionItem.h"
#import "PrefPage.h"


@interface PrefCheckForUpdatesActionItem : PrefThreadedActionItem {

	PrefPage*	_itemsForUpdatePage;
}
@property (retain) PrefPage* itemsForUpdatePage;

@end
