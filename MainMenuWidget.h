//
//  MainMenuWidget.h
//  Board3
//
//  Created by Dror Kessler on 6/13/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasView.h"
#import "PieceEventsTarget.h"
#import "PieceDispensingTarget.h"
#import "GameBoardLogic.h"
#import "CompoundBoard.h"
#import "SoundTheme.h"
#import "WidgetBase.h"
#import "Banner.h"
#import "BrandManager.h"
#import "UserPrefs.h"

@interface MainMenuWidget : WidgetBase<HasView,PieceEventsTarget,PieceDispensingTarget,BrandManagerDelegate> {

	int				cellSize;
	NSMutableArray*	_entries;

	UIView*			_view;
	UIView*			_dispenserView;
	
	CompoundBoard*		_mainBoard;
	id<GameBoardLogic>	_mainBoardGBL;
	
	SoundTheme*		_soundTheme;
	
	NSTimer*		_timer;
	
	SEL				preferencesAction;
	id<NSObject>	_preferencesTarget;
	
	Banner*			_banner;
	UIButton*		_prefButton;
	
	BOOL			disabled;
	
	UIImage*		_tickWaveImage;
	
	id<Board>		_gameSelectionBoard;
	NSString*		_gameSelectionUUIDs;
}
@property (retain) NSMutableArray* entries;
@property (retain) UIView* view;
@property (retain) UIView* dispenserView;
@property (retain) CompoundBoard* mainBoard;
@property (retain) id<GameBoardLogic> mainBoardGBL;
@property (retain) SoundTheme* soundTheme;
@property (retain) NSTimer* timer;
@property (retain) id<NSObject> preferencesTarget;
@property int cellSize;
@property (retain) Banner* banner;
@property (retain) UIButton* prefButton;
@property BOOL disabled;
@property (retain) UIImage* tickWaveImage;
@property (retain) id<Board> gameSelectionBoard;
@property (retain) NSString* gameSelectionUUIDs;

-(int)addEntry:(NSString*)text;
-(void)setEntryAction:(SEL)action withTarget:(id<NSObject>)target atIndex:(int)index;
-(void)setPreferencesAction:(SEL)action withTarget:(id<NSObject>)target;
-(void)paintEntries;
-(void)reset;
-(void)appeared;
-(void)willAppear;
-(void)disappeared;
-(int)entryCount;


@end
