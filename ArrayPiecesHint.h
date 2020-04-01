//
//  ArrayPiecesHint.h
//  Board3
//
//  Created by Dror Kessler on 5/20/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PiecesHint.h"

@interface ArrayPiecesHint : NSObject<PiecesHint> {

	NSArray*	_pieces;
}
@property (retain) NSArray* pieces;

-(id)initWithPieces:(NSArray*)pieces;


@end
