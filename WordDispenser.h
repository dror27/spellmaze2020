/*
 *  WordDispenser.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/13/09.
 *  Copyright 2020 Dror Kessler (M). All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

@protocol WordDispenser<NSObject>

-(NSString*)dispense;
-(BOOL)canDispense;

-(float)progress;

@end
