//
//  CellView.h
//  Board3
//
//  Created by Dror Kessler on 5/8/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>

@class Cell;

@interface CellView : UIView {

	Cell*		_model;
	BOOL		highlight;
}
@property (nonatomic,assign) Cell* model;
@property BOOL highlight;

- (id)initWithFrame:(CGRect)frame andCell:(Cell*)initCell;
@end
