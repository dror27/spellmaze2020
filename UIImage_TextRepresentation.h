//
//  UIImage_TextRepresentation.h
//  Board3
//
//  Created by Dror Kessler on 8/27/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>


@interface UIImage (TextRepresentation)

-(NSString*)textRepresentation;
+(UIImage*)imageFromTextRepresentation:(NSString*)textRepresentation;

@end
