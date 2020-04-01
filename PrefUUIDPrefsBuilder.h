//
//  PrefUUIDPrefsBuilder.h
//  Board3
//
//  Created by Dror Kessler on 8/19/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

@class PrefPage, PrefSection, PrefItemBase, GameLevelSequence;
@interface PrefUUIDPrefsBuilder : NSObject {

}
-(PrefPage*)pageForGameLevelSequence:(GameLevelSequence*)seq;


-(PrefPage*)pageForUUID:(NSString*)uuid forDomain:(NSString*)domain fromArray:(NSArray*)array;
-(PrefSection*)sectionForUUID:(NSString*)uuid forDomain:(NSString*)domain fromDictionary:(NSDictionary*)dict;
-(PrefItemBase*)itemForUUID:(NSString*)uuid forDomain:(NSString*)domain fromDictionary:(NSDictionary*)dict;


@end
