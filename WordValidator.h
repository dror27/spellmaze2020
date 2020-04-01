/*
 *  WordValidator.h
 *  Board3
 *
 *  Created by Dror Kessler on 7/20/09.
 *  Copyright 2009 Dror Kessler (M). All rights reserved.
 *
 */

@class CSetWrapper;

@protocol WordValidator <NSObject>

-(NSString*)isValidWord:(NSString*)word withBlackList:(CSetWrapper*)blackList withWhiteListWords:(NSSet*)whiteListWords;
-(CSetWrapper*)getValidWordSet:(const unichar*)chars withCharsNum:(int)charsNum withMinWordSize:(int)minWordSize withMaxWordSize:(int)maxWordSize andBlackList:(CSetWrapper*)blackList;

-(NSString*)getValidWordByIndex:(int)index;
-(unichar)getValidWordCharacterByIndex:(int)index characterAt:(int)charIndex;


-(void)wordDispensed:(NSString*)word;
-(void)wordCompleted:(NSString*)word;

-(NSString*)wordForHintWord:(NSString*)word;

@end
