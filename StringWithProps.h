//
//  StringWithProps.h
//  SpellMaze
//
//  Created by Dror Kessler on 12/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringWithProps : NSString {

	NSMutableDictionary*	_props;
}
@property (retain) NSMutableDictionary* props;

@end
