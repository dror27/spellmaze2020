//
//  ImagePieceDecorator.h
//  Board3
//
//  Created by Dror Kessler on 8/28/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PieceDecorator.h"

@interface ImagePieceDecorator : NSObject<PieceDecorator> {

	UIImage*		_image;
	float			_xPos;		// in precentage of width {0,1}
	float			_yPos;		// in precentage of height {0,1}
	BOOL			_bounce;	// bounce animation enabled?
	
	UIImageView*	_imageView;	// available only when decorating
}
@property (retain) UIImage*	image;
@property (retain) UIImageView* imageView;
@property float xPos;
@property float yPos;
@property BOOL bounce;

@end
