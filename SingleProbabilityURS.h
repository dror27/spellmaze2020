//
//  SingleProbabilityURS.h
//  Board3
//
//  Created by Dror Kessler on 10/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniformRandomSeries.h"

@interface SingleProbabilityURS : NSObject<UniformRandomSeries> {

	int		n;				// number of generated elements
	int		k;				// number of TRUE elements
	double	p;				// the probability
}
@property double probability;
-(id)initWithProbability:(double)probability;

@end
