//
//  FormulaEvaluator.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FormulaEvaluator.h"
#import "JIMInterp.h"
#import "BrandManager.h"


@implementation FormulaEvaluator

+(FormulaEvaluator*)evaluator
{
	return [[[FormulaEvaluator alloc] init] autorelease];
}

-(id)eval:(NSString*)formula
{
	// simple cases
	if ( !formula || ![formula length] )
		return NULL;
	
	// switch on first character
	unichar		ch0 = [formula characterAtIndex:0];
	switch ( ch0 ) 
	{
#if	SCRIPTING
		case '=' :
		{
			// jim expression
			return [self eval:[[JIMInterp interp] eval:[formula substringFromIndex:1]]];
		}
#endif
			
		case '!' :
		{
			// brand file contents
			NSString*		path = [[BrandManager currentBrand] resourcePath:[formula substringFromIndex:0]];
			if ( !path )
				return NULL;
			return [self eval:[NSString stringWithContentsOfFile:path]];
		}
			
		default :
		{
			if ( [formula hasPrefix:@"http://"] )
			{
				// url
				return [self eval:[NSString stringWithContentsOfURL:[NSURL URLWithString:formula]]];
			}
			else
			{
				// simply a string
				return formula;
			}
		}
	}
}

-(NSString*)evalToString:(NSString*)formula
{
	return [[self eval:formula] description];
}


@end
