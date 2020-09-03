//
//  PrefCompoundSection.m
//  SpellMaze
//
//  Created by Dror Kessler on 12/25/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefCompoundSection.h"


@implementation PrefCompoundSection
@synthesize sections = _sections;

-(void)dealloc
{
	[_sections release];
	
	[super dealloc];
}

-(NSArray*)items
{
	NSMutableArray*		result = [NSMutableArray array];
	
	for ( PrefSection* section in self.sections )
		[result addObjectsFromArray:section.items];
	
	return result;
}

@end
