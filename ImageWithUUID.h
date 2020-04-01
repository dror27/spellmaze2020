//
//  ImageWithUUID.h
//  SpellMaze
//
//  Created by Dror Kessler on 12/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageWithUUID : UIImage {

	NSString*	_uuid;
	time_t		lastTimeUsed;
	NSString*	_key;
}
@property (retain) NSString* uuid;
@property time_t lastTimeUsed;
@property (retain) NSString* key;

@end
