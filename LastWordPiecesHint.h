//
//  LastWordPiecesHint.h
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiecesHint.h"

@interface LastWordPiecesHint : NSObject<PiecesHint> {

	int					wordId;
	int					wordSize;
	NSMutableArray*		_pieces;
}
@property (retain) NSMutableArray* pieces;

-(void)registerPiece:(id<Piece>)piece;

@end
