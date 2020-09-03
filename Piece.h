//
//  Piece.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HasView.h"
#import "PieceDispensingHints.h"
#import "PieceEventsTarget.h"

@class Cell;
@protocol Piece<NSObject,HasView>

@property (nonatomic,assign) Cell* cell;
@property (retain) NSMutableDictionary* props;
@property float fade;
@property BOOL disabled;
@property BOOL hidden;
@property (nonatomic,assign) id<PieceEventsTarget> eventsTarget;

-(void)appendTo:(NSMutableString*)s;
-(void)reset;
-(void)eliminate;
-(void)examine;

-(void)clicked;
-(void)disabledClicked;
-(void)hinted:(BOOL)last;
-(void)select;
-(void)deselect;
-(BOOL)selected;

-(BOOL)sameContentAs:(id<Piece>)piece;
-(NSString*)text;
-(void)setText:(NSString*)text;

-(void)addDecorator:(NSString*)decoratorName;
-(void)removeDecorator:(NSString*)decoratorName;
-(BOOL)hasDecorator:(NSString*)decoratorName;

#define		DECORATOR_CHECKED		@"CheckedPieceDecorator"
#define		DECORATOR_CHECKED2		@"CheckedPieceDecorator2"
#define		DECORATOR_APPLE			@"ApplePieceDecorator"
#define		DECORATOR_BOMB			@"BombPieceDecorator"
#define		DECORATOR_COIN			@"CoinPieceDecorator"

#define		DECORATOR_DIGIT			@"DigitPieceDecorator"

@end
