//
//  SymbolPieceView.h
//  Board3
//
//  Created by Dror Kessler on 5/8/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieceView.h"
#import "BrandManager.h"

@class SymbolPiece;
@interface SymbolPieceView : UIView<PieceView,BrandManagerDelegate,UserPrefsDelegate> {

	SymbolPiece*	_model;
	float			lastScreenX;
	float			lastScreenY;
	CGSize			lastScreenSize;
	
	UIView*			_contentView;
	UIView*			_fadeView;
	
	float			fade;
	BOOL			disabled;
	BOOL			hidden;
	
	int				colorIndex;
	BOOL			noFadeView;
	BOOL			fastAnimations;
}
@property (nonatomic,assign) SymbolPiece* model;
@property float fade;
@property BOOL disabled;
@property BOOL hidden;
@property float lastScreenX;
@property float lastScreenY;
@property CGSize lastScreenSize;
@property (retain) UIView* contentView;
@property (retain) UIView* fadeView;
@property BOOL noFadeView;

-(id)initWithFrame:(CGRect)frame andModel:(SymbolPiece*)initModel;
-(void)updateSelected:(BOOL)isSelected;

-(void)updateText;
-(UIView*)buildContentView:(BOOL)fadeMask;

+(void)guardImageDictSize:(BOOL)inGame;






@end
