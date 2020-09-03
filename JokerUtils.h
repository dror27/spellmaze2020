//
//  JokerUtils.h
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Piece.h"

@interface JokerUtils : NSObject {

}
+(UIImage*)jokerImage;
+(float)globalJokerProb;
+(unichar)jokerCharacter;
+(int)maxJokersInWord;
+(BOOL)containsJoker:(NSString*)word;
+(BOOL)pieceIsJoker:(id<Piece>)piece;

@end
