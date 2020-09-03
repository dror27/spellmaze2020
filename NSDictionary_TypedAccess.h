//
//  NSDictionary_TypedAccess.h
//  Board3
//
//  Created by Dror Kessler on 8/7/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (TypedAccess) 

-(BOOL)hasKey:(NSString*)key;

-(BOOL)booleanForKey:(NSString*)key withDefaultValue:(BOOL)defaultValue;
-(int)integerForKey:(NSString*)key withDefaultValue:(int)defaultValue;
-(NSString*)stringForKey:(NSString*)key withDefaultValue:(NSString*)defaultValue;
-(float)floatForKey:(NSString*)key withDefaultValue:(float)defaultValue;

-(NSArray*)arrayForKey:(NSString*)key withDefaultValue:(NSArray*)defaultValue;
-(NSDictionary*)dictionaryForKey:(NSString*)key withDefaultValue:(NSDictionary*)defaultValue;
-(id)objectForKey:(NSString*)key withDefaultValue:(id)defaultValue;


-(NSDictionary*)leafDictionaryForKey:(NSString*)key leafKey:(NSString**)leafKeyOutput;

@end
