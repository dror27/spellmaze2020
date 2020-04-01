//
//  CSetWrapper.m
//  Board3
//
//  Created by Dror Kessler on 5/18/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "CSetWrapper.h"
#import "CSet_NS.h"

@implementation CSetWrapper
@synthesize cs = _cs;
@synthesize invertedCS = _invertedCS;

-(id)init
{
	if ( self = [super init] )
		_cs = CSet_Alloc(0);
	return self;
}

-(id)initWithInitialAllocation:(int)initialAllocation andSorted:(BOOL)sorted
{
	if ( self = [super init] )
	{
		_cs = CSet_Alloc(initialAllocation);
		_cs->sorted = sorted;
	}
	return self;	
}
-(id)initWithCSet:(CSet*)initCs
{
	if ( self = [super init] )
		_cs = initCs;
	return self;	
}

-(void)dealloc
{
	if ( _cs )
		CSet_Free(_cs);
	if ( _invertedCS && !invertedCSisShared )
		CSet_Free(_invertedCS);
	
	[super dealloc];
}

-(void)NSLog
{
	CSet_NSLog(_cs);
}

-(void)NSLogWithElementsNames:(NSArray*)names andPrefix:(NSString*)prefix
{
	CSet_NSLogWithElementsNames(_cs, names, prefix);
}	

-(CSet*)invertedCS:(CSet*)all
{
	@synchronized (self)
	{
		if ( !_invertedCS )
		{
			//NSLog(@"Inverting %p - %@ (%d)", self, self, _cs->size);
			
			if ( _cs->size )
			{
				_invertedCS = CSet_Alloc(all->size - _cs->size);
				CSet_CopyInverted(_cs, _invertedCS, 0, all->size - 1);
				invertedCSisShared = FALSE;
			}
			else
			{
				_invertedCS = all;
				invertedCSisShared = TRUE;
			}
		}
	}
	
	return _invertedCS;
}

@end
