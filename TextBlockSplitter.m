//
//  TextBlockSplitter.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextBlockSplitter.h"


@implementation TextBlockSplitter

+(TextBlockSplitter*)splitter
{
	return [[[TextBlockSplitter alloc] init] autorelease];
}

-(NSArray*)split:(NSString*)text;
{
	if ( !text || ![text length] )
		return NULL;
	
	NSMutableArray*		lines = [NSMutableArray array];
	NSCharacterSet*		whites = [NSCharacterSet whitespaceCharacterSet];
	
	for ( NSString* line in [text componentsSeparatedByString:@"\n"] )
	{
		line = [line stringByTrimmingCharactersInSet:whites];
		if ( ![line length] || [line characterAtIndex:0] == '#' )
			continue;
		
		[lines addObject:line];
	}
	
	return lines;
}


@end
