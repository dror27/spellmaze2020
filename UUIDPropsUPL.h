//
//  UUIDPropsUPL.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserPrefsLayer.h"


@interface UUIDPropsUPL : NSObject<UserPrefsLayer> {

	NSString*			_uuid;
	NSDictionary*		_props;
	id<UserPrefsLayer>	_nextLayer;
}
@property (retain) NSString* uuid;
@property (retain) NSDictionary* props;
@property (retain) id<UserPrefsLayer> nextLayer;

-(id)initWithUUID:(NSString*)uuid andProps:(NSDictionary*)props andNextLayer:(id<UserPrefsLayer>)nextLayer;

@end
