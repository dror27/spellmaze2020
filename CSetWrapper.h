//
//  CSetWrapper.h
//  Board3
//
//  Created by Dror Kessler on 5/18/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSet.h"
#import "CSet_NS.h"

// CSet Wrapper
@interface CSetWrapper : NSObject
{
	CSet*	_cs;
	CSet*	_invertedCS;
	BOOL	invertedCSisShared;
}
@property CSet* cs;
@property CSet* invertedCS;

-(id)initWithCSet:(CSet*)initCs;
-(id)initWithInitialAllocation:(int)initialAllocation andSorted:(BOOL)sorted;
-(void)NSLog;
-(void)NSLogWithElementsNames:(NSArray*)names andPrefix:(NSString*)prefix;

-(CSet*)invertedCS:(CSet*)all;


@end

