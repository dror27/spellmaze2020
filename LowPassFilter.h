//
//  LowPassFilter.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LowPassFilter : NSObject {

	double		*_values;
	int			count;
	int			depth;	
}
-(id)initWithDepth:(int)depth;
-(double)pass:(double)value;

@end
