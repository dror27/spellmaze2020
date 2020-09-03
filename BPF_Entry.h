//
//  BPF_Entry.h
//  Board3
//
//  Created by Dror Kessler on 7/21/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

@class BPF_Entry;
@interface BPF_Entry : NSObject {

	unichar		symbol;
	float		weight;
	float		score;
	BPF_Entry*	_prefix;
}
@property unichar symbol;
@property float weight;
@property float score;
@property (retain) BPF_Entry* prefix;

-(enum _NSComparisonResult)orderAgainst:(BPF_Entry*)other;
-(unichar)prefixSymbol;
-(NSString*)prefixString;

@end
