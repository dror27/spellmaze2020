//
//  ViewTransformerGBL.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/17/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameBoardLogicBase.h"
#import "LowPassFilter.h"


@interface ViewTransformerGBL : GameBoardLogicBase<UIAccelerometerDelegate> {

	int					rotationSlices;			// of a full circle
	NSString*			_rotationEvent;			// name of GameBoardLogic method to rotate on
	BOOL				resetAtEnd;				// reset when Won or Over?
	BOOL				followDevice;			// follow device accelerometer?
	int					deviceLPF;				// low pass filter depth
	int					deviceSlices;			// of a full circle (0 = do not slice)
	
	double				rotation;				// the current rotation
	
	UIAccelerometer*	_accelerometer;			// the shared instance
	
	LowPassFilter*		_xFilter;
	LowPassFilter*		_yFilter;
	
	BOOL				ended;
	BOOL				flipped;
}

@property int	rotationSlices;
@property (retain) NSString* rotationEvent;
@property BOOL resetAtEnd;
@property (retain) UIAccelerometer*	accelerometer;
@property (retain) LowPassFilter* xFilter;
@property (retain) LowPassFilter* yFilter;
@property BOOL followDevice;
@property int deviceLPF;
@property int deviceSlices;
@end
