//
//  NSData_TextRepresentation.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (TextRepresentation) 

-(NSString*)textRepresentation;
+(NSData*)dataFromTextRepresentation:(NSString*)textRepresentation;

@end
