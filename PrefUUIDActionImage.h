//
//  PrefUUIDActionImage.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefImageItem.h"


@interface PrefUUIDActionImage : PrefImageItem {
	NSString*		_uuid;
	NSString*		_param;
}

@property (retain) NSString* uuid;
@property (retain) NSString* param;

@end
