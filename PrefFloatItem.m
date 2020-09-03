//
//  PrefFloatItem.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefFloatItem.h"
#import "Constants.h"
#import "UserPrefs.h"
#import <math.h>


@interface PrefFloatItem (Priavtes)
-(UITextAlignment)textAlignment;
@end


@implementation PrefFloatItem
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;
@synthesize defaultValue = _defaultValue;
@synthesize logarithmicScale = _logarithmicScale;
@synthesize showValue = _showValue;
@synthesize integerValuesOnly = _integerValuesOnly;
@synthesize sliderControl = _sliderControl;
@synthesize valueLabel = _valueLabel;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andMinValue:(float)minValue andMaxValue:(float)maxValue andDefaultFloatValue:(float)defaultValue
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.minValue = minValue;
		self.maxValue = maxValue;
		self.defaultValue = defaultValue;
	}
	return self;	
}

-(id)initLogarithmicWithLabel:(NSString*)label andKey:(NSString*)key andMinValue:(float)minValue andMaxValue:(float)maxValue andDefaultFloatValue:(float)defaultValue
{
	if ( self = [self initWithLabel:label andKey:key andMinValue:minValue andMaxValue:maxValue andDefaultFloatValue:defaultValue] )
	{
		self.logarithmicScale = TRUE;
	}
	return self;	
}

-(void)dealloc
{
	[_sliderControl release];
	[_valueLabel release];
	
	[super dealloc];
}

-(UIView*)control
{
	if ( !_control )
	{
		CGRect		sliderFrame = CGRectMake(0.0, 0.0, 120.0, kSliderHeight);
		
		self.sliderControl = [[[UISlider alloc] initWithFrame:sliderFrame] autorelease];
				
		[_sliderControl addTarget:self action:@selector(valueChangedAction:) forControlEvents:UIControlEventValueChanged];
		_sliderControl.backgroundColor = [UIColor clearColor];
		
		_sliderControl.minimumValue = self.logarithmicScale ? log2f(self.minValue) : self.minValue;
		_sliderControl.maximumValue = self.logarithmicScale ? log2f(self.maxValue) : self.maxValue;
		_sliderControl.continuous = self.showValue;
		if ( !self.integerValuesOnly )
			_sliderControl.value = self.logarithmicScale 
								? log2f([UserPrefs getFloat:self.key withDefault:self.defaultValue])
								: [UserPrefs getFloat:self.key withDefault:self.defaultValue];
		else
			_sliderControl.value = [UserPrefs getInteger:self.key withDefault:(int)self.defaultValue];
		
		
		//NSLog(@"PrefFloatItem: %f %f %f", _sliderControl.minimumValue, _sliderControl.maximumValue, _sliderControl.value);

		if ( self.showValue )
		{
			CGRect		labelFrame = CGRectMake(5.0, 0.0, 110.0, kSliderHeight);
			self.valueLabel = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
			_valueLabel.backgroundColor = [UIColor clearColor];
			_valueLabel.font = [UIFont systemFontOfSize:10];
			_valueLabel.textAlignment = [self textAlignment];
			
			float		value = self.logarithmicScale ? exp2f(_sliderControl.value) : _sliderControl.value;
			if ( !self.integerValuesOnly )
				_valueLabel.text = [NSString stringWithFormat:@"%.2f", value];
			else
				_valueLabel.text = [NSString stringWithFormat:@"%d", (int)value];
			
			[_sliderControl addSubview:_valueLabel];
		}
		
		self.control = _sliderControl;
	}
	
	return _control;
}

-(void)valueChangedAction:(id)sender
{
	float		value = self.logarithmicScale ? exp2f(_sliderControl.value) : _sliderControl.value;
	
	if ( self.integerValuesOnly )
		value = round(value);
	
	if ( !self.integerValuesOnly )
		[UserPrefs setFloat:self.key withValue:value];
	else
		[UserPrefs setInteger:self.key withValue:(int)value];
		
	
	if ( self.showValue )
	{
		if ( !self.integerValuesOnly )
			_valueLabel.text = [NSString stringWithFormat:@"%.2f", value];
		else
			_valueLabel.text = [NSString stringWithFormat:@"%d", (int)value];
		
		_valueLabel.textAlignment = [self textAlignment];
	}

	[self wasChanged];
}

-(void)refresh
{
	if ( self.control )
	{
		if ( !self.integerValuesOnly )
			((UISlider*)self.control).value = self.logarithmicScale 
				? log2f([UserPrefs getFloat:self.key withDefault:self.defaultValue])
				: [UserPrefs getFloat:self.key withDefault:self.defaultValue];
		else
			((UISlider*)self.control).value = [UserPrefs getInteger:self.key withDefault:(int)self.defaultValue];
		
		
	}
}

-(UITextAlignment)textAlignment
{
	float		value = _sliderControl.value;
	float		mid = (_sliderControl.minimumValue + _sliderControl.maximumValue) / 2;
	
	return value > mid ? UITextAlignmentLeft : UITextAlignmentRight;
}
@end
