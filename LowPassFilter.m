//
//  LowPassFilter.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/18/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "LowPassFilter.h"


@implementation LowPassFilter

-(id)init
{
	return [self initWithDepth:5];
}

-(id)initWithDepth:(int)initDepth
{
	if ( self = [super init] )
	{
		depth = initDepth ? initDepth : 5;
		count = 0;
		_values = calloc(depth, sizeof(double));
	}
	return self;
}

-(void)dealloc
{
	if ( _values )
		free(_values);
	
	[super dealloc];
}

-(double)pass:(double)value
{
	// push value into the filter values
	if ( count >= depth )
		count = depth - 1;
	if ( count )
		memcpy(_values + 1, _values, count * sizeof(double));
	_values[0] = value;
	count++;
	
	// calc filter (avarage) value
	double	sum = 0.0;
	for ( int n = 0 ; n < count ; n++ )
		sum += _values[n];
	double	avarage = sum / count;
	
	return avarage;
}

@end
