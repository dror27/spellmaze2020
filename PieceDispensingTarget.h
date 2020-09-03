/*
 *  PieceDispensingTarget.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/13/09.
 *  Copyright 2020 Dror Kessler (M). All rights reserved.
 *
 */

#import "Piece.h"
#import	"PieceDispensingHints.h"
#import "Language.h"

@protocol PieceDispensingTarget<NSObject>

-(void)onDispensingStarted;
-(void)onDispensingStopped;
-(void)onNoMorePieces;
-(BOOL)onWillAcceptPiece;
-(void)onPieceDispensed:(id<Piece>)piece withContext:(void*)context;
-(float)targetFullness;		// 0.0 - empty, 1.0 - full
-(float)targetProgress;		// 0.0 - nothing good has ever happend ..., 1.0 - things are really flying here ...
-(id<Language>)targetLanguage;
@end
