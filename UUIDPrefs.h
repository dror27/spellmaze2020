//
//  UUIDPrefs.h
//  Board3
//
//  Created by Dror Kessler on 9/6/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UUIDPrefs : NSObject {

}
+(NSArray*)splitUUIDKey:(NSString*)key;
+(NSDictionary*)findLoadedUUIDProps:(NSString*)uuid;
+(NSDictionary*)findLoadedUUIDPrefsData:(NSString*)uuid;
+(NSDictionary*)findLoadedUUIDPrefsDataForKey:(NSString**)key;

@end
