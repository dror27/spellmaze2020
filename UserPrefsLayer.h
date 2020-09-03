//
//  UserPrefsLayer.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/20/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol UserPrefsLayer<NSObject>

-(BOOL)hasKey:(NSString*)key;
-(NSString*)getString:(NSString*)key withDefault:(NSString*)value;
-(int)getInteger:(NSString*)key withDefault:(int)value;
-(BOOL)getBoolean:(NSString*)key withDefault:(BOOL)value;
-(float)getFloat:(NSString*)key withDefault:(float)value;

-(id)getObject:(NSString*)key withDefault:(id)value;

@end
