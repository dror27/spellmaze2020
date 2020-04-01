/*
 *  PieceDispensingHints.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/13/09.
 *  Copyright 2009 Dror Kessler (M). All rights reserved.
 *
 */

@protocol PieceDispensingHints<NSObject>

-(BOOL)hasHint:(NSString*)name;
-(NSString*)stringHint:(NSString*)name;
-(int)intHint:(NSString*)name;

@end

