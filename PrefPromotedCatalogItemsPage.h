//
//  PrefPromotedCatalogItemsPage.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefPage.h"


@interface PrefPromotedCatalogItemsPage : PrefPage {

	NSArray*	_catalogItems;
	
}
@property (retain) NSArray* catalogItems;

-(id)initWithCatalogItems:(NSArray*)catalogItems;
@end
