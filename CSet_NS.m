/*
 * CSet_NS.m
 *
 *  Created on: May 18, 2020
 *      Author: dror
 */

#include "CSet.h"
#import "CSet_NS.h"

#define	MAX_ELEMS_TO_LOG		100

void
CSet_NSLog(CSet* cs)
{
	CSet_NSLogWithElementsNames(cs, NULL, NULL);
}

void	CSet_NSLogWithElementsNames(CSet* cs, NSArray* names, NSString* prefix)
{
	NSMutableString*		s = [[NSMutableString alloc] init];
	
	if ( prefix )
	{
		[s appendString:prefix];
		[s appendString:@" "];
	}
	[s appendFormat:@"(%d) ", cs->size];
	[s appendString:@"{"];
	
	T_ELEM		*p1, *pend = cs->elems + cs->size;
	int			index = 0;
	for ( p1 = cs->elems ; p1 < pend ; p1++, index++ )
	{
		if ( index >= MAX_ELEMS_TO_LOG )
		{
			[s appendString:@"..."];
			break;
		}
		
		if ( index )
			[s appendString:@","];
		
		if ( names )
			[s appendFormat:@"%@", [names objectAtIndex:*p1]];
		else
			 [s appendFormat:@"%d", *p1];
	}
	[s appendString:@"}"];
	
	NSLog(s);
}
