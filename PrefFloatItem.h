//
//  PrefFloatItem.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PrefItemBase.h"


@interface PrefFloatItem : PrefItemBase {

	float	_minValue;
	float	_maxValue;
	float	_defaultValue;
	
	BOOL	_logarithmicScale;
	BOOL	_showValue;
	
	UISlider*	_sliderControl;
	UILabel*	_valueLabel;
	
	BOOL		_integerValuesOnly;
}
@property float minValue;
@property float maxValue;
@property float	defaultValue;
@property BOOL logarithmicScale;
@property BOOL showValue;
@property BOOL integerValuesOnly;

@property (retain) UISlider* sliderControl;
@property (retain) UILabel* valueLabel;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andMinValue:(float)minValue andMaxValue:(float)maxValue andDefaultFloatValue:(float)defaultValue;
-(id)initLogarithmicWithLabel:(NSString*)label andKey:(NSString*)key andMinValue:(float)minValue andMaxValue:(float)maxValue andDefaultFloatValue:(float)defaultValue;

@end
