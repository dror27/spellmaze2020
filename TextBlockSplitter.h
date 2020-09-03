//
//  TextBlockSplitter.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/16/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextBlockSplitter : NSObject {

}
+(TextBlockSplitter*)splitter;

-(NSArray*)split:(NSString*)text;
@end
