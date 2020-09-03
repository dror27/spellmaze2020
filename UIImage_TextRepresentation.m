//
//  UIImage_TextRepresentation.m
//  Board3
//
//  Created by Dror Kessler on 8/27/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "UIImage_TextRepresentation.h"
#import "NSData_TextRepresentation.h"


@implementation UIImage (TextRepresentation)

-(NSString*)textRepresentation
{
	NSData*					imageData = UIImageJPEGRepresentation(self, 0.8);
	
	return [imageData textRepresentation];
}

+(UIImage*)imageFromTextRepresentation:(NSString*)textRepresentation
{
	if ( !textRepresentation )
		return NULL;
	
	NSData*		imageData = [NSData dataFromTextRepresentation:textRepresentation];
	
	return [UIImage imageWithData:imageData];
}


@end
