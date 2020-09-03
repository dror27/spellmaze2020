//
//  WordInfo.h
//  Board3
//
//  Created by Dror Kessler on 7/27/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	WI_VALID, WI_INVALID, WI_ADDED, WI_BLACKLISTED
} GameLevel_WordInfo_Type;

@interface GameLevel_WordInfo : NSObject {

	int						count;
	GameLevel_WordInfo_Type	type;
	
	int						scoreContrib;
	BOOL					scoreContribFancy;
}
@property int count;
@property GameLevel_WordInfo_Type type;
@property int scoreContrib;
@property BOOL scoreContribFancy;

@end
