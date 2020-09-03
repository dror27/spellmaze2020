//
//  SymbolDispenser.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SymbolDispenser<NSObject>

-(unichar)dispense:(NSMutableDictionary*)hints;
-(BOOL)canDispense;

-(float)progress;
-(int)symbolsLeft;

-(BOOL)rushDispensing;

@property (retain) NSMutableString* rushSymbols;

@end
