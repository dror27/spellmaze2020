//
//  EnvelopeDynamics.h
//  Board3
//
//  Created by Dror Kessler on 8/19/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct 
{
	float		duration;
	float		alpha;
} EnvelopeDynamicsPoint;

typedef enum
{
	EnvelopeDynamicsPointTypeAttack = 0,
	EnvelopeDynamicsPointTypeSustain,
	EnvelopeDynamicsPointTypeDecay,
	EnvelopeDynamicsPointTypeCount
} EnvelopeDynamicsPointType;


@interface EnvelopeDynamics : NSObject {

@public
	EnvelopeDynamicsPoint	points[EnvelopeDynamicsPointTypeCount];
}

@end
