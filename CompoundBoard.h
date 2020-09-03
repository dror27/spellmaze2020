//
//  CompoundBoard.h
//  Board3
//
//  Created by Dror Kessler on 6/9/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Board.h"

@class GameLevel;
@interface CompoundBoard : NSObject<Board> {

	NSMutableArray*		_boards;
	GameLevel*			_level;
	UIView*				_view;
	
	CGRect				suggestedFrame;
}
@property (retain) NSMutableArray* boards;
@property (retain) UIView* view;
@property CGRect suggestedFrame;

+(id<Board>)boardByFormula:(NSString*)boardFormula;

-(void)addBoard:(id<Board>)board withFrame:(CGRect)frame;
-(void)addBoard:(id<Board>)board withX:(int)x andY:(int)y andWidth:(int)width andHeight:(int)height;
@end
