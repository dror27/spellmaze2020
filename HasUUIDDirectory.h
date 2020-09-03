//
//  HasUUIDDirectory.h
//  Board3
//
//  Created by Dror Kessler on 9/6/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasUUID.h"

@protocol HasUUIDDirectory<NSObject> 
-(id<HasUUID>)findHasUUID:(NSString*)uuid;
@end
