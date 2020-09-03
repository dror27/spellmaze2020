//
//  FreeStore.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/28/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreManager.h"


@interface FreeStore : NSObject<StoreImplementation> {

	StoreManager*	_storeManager;
}
@property (nonatomic,assign) StoreManager* storeManager;

-(id)initWithStoreManager:(StoreManager*)storeManager;

@end
