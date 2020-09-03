//
//  PieceDispensingHintsImpl.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PieceDispensingHints.h"

@interface PieceDispensingHintsImpl : NSObject<PieceDispensingHints> {

	NSMutableDictionary*		_hints;
}
@property (retain) NSMutableDictionary* hints;

-(void)addStringHint:(NSString*)name withValue:(NSString*)value;
-(void)addIntHint:(NSString*)name withValue:(int)value;

@end
