//
//  GridBoardPieceDispenserPieceArray.h
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridBoardPieceDispenserBase.h"

@interface GridBoardPieceDispenserPieceArray : GridBoardPieceDispenserBase {

	NSArray*			_pieces;
	int					index;
}
@property (retain) NSArray* pieces;

@end
