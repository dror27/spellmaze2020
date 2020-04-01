//
//  UUIDUtils.h
//  Board3
//
//  Created by Dror Kessler on 8/26/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UUIDUtils : NSObject {

}
+(NSString*)createUUID;
+(BOOL)isUUID:(NSString*)uuid;
+(NSString*)strip:(NSString*)uuid;

@end
