//
//  ShapeDecorationImageBuilder.h
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImagePieceDecorator.h"

@interface ShapeDecorationImageBuilder : NSObject {

	UIColor*		_shapeBorderColor;
	UIColor*		_shapeFillColor;
	
	UIColor*		_symbolColor;
	
	NSArray*		_symbolLines;		// NSArray of NSArray of NSValue(CGPoint) - {-1,1} from width/height 
	
	float			_radius;			// generally set at 12.0
	
	NSString*		_text;
}
@property (retain) UIColor* shapeBorderColor;
@property (retain) UIColor* shapeFillColor;
@property (retain) UIColor*	symbolColor;
@property (retain) NSArray* symbolLines;
@property float radius;
@property (retain) NSString* text;

-(UIImage*)image;

@end
