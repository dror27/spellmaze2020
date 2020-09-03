#if SCRIPTING
//
//  ByUUIDGameLevelFactory.h
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameLevelFactory.h"
#import "ByScriptGameLevelFactory.h"


@interface ByUUIDGameLevelFactory : ByScriptGameLevelFactory {

}
-(id)initWithUUID:(NSString*)uuid;
-(id)initWithProps:(NSDictionary*)props;

@end
#endif
