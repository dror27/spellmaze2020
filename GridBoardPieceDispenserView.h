//
//  GridBoardPieceDispenserView.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>

@class GridBoardPieceDispenserBase;

@interface GridBoardPieceDispenserView : UIView {

	GridBoardPieceDispenserBase*	_model;
}
@property (nonatomic,assign) GridBoardPieceDispenserBase* model;

-(id)initWithFrame:(CGRect)frame andModel:(GridBoardPieceDispenserBase*)initModel;

@end
