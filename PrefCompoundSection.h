//
//  PrefCompoundSection.h
//  SpellMaze
//
//  Created by Dror Kessler on 12/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefSection.h"


@interface PrefCompoundSection : PrefSection {

	NSArray*		_sections;
}
@property (retain) NSArray*		sections;

@end
