//
//  ItemSelectorWidget.h
//  Board3
//
//  Created by Dror Kessler on 6/16/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasView.h"
#import "PieceEventsTarget.h"
#import "Board.h"
#import "WidgetBase.h"

@class SoundTheme;
@class ScoreWidget;

@interface ItemSelectorWidget : WidgetBase<HasView,PieceEventsTarget> {

	int				cellSize;
	NSMutableArray*	_items;
	
	UIView*			_view;
	
	id<Board>		_board;
	ScoreWidget*	_panel;
	
	SoundTheme*		_soundTheme;	
	
	BOOL			speakSelection;
	BOOL			painted;
	BOOL			hideDisabledItems;
	
	NSString*		_boardFormula;
}
@property (retain) NSMutableArray* items;
@property (retain) UIView* view;
@property (retain) id<Board> board;
@property (retain) ScoreWidget* panel;
@property (retain) SoundTheme* soundTheme;
@property int cellSize;
@property BOOL speakSelection;
@property BOOL hideDisabledItems;
@property (retain) NSString* boardFormula;

-(int)addItem:(NSString*)title andShortDescription:(NSString*)shortDescription;
-(void)setItemAction:(SEL)action withTarget:(id<NSObject>)target atIndex:(int)index;
-(void)setItemEnabled:(BOOL)enabled atIndex:(int)index;
-(void)setItemChecked:(BOOL)checked atIndex:(int)index;
-(void)setItemChecked2:(BOOL)checked atIndex:(int)index;
-(void)setItemLabel:(NSString*)label atIndex:(int)index;
-(NSMutableDictionary*)itemPropsAtIndex:(int)index;
-(void)paintItems;
-(void)reset;
-(void)appeared;
-(void)disappeared;
-(void)setMessage:(NSString*)message andSubMessage:(NSString*)subMessage;
-(int)itemCount;

@end
