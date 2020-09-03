//
//  BoardView.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridBoard.h"
#import "BrandManager.h"

@interface GridBoardView : UIView<BrandManagerDelegate> {

	GridBoard*		_model;
	
	float			cellWidth;
	float			cellHeight;
	float			cellMargin;
}
@property (nonatomic,assign) GridBoard* model;
@property float cellWidth;
@property float cellHeight;
@property float cellMargin;

- (id)initWithFrame:(CGRect)frame andBoard:(GridBoard*)initBoard;
- (CGRect)cellRectAt:(int)x andY:(int)y;

@end
