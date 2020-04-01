//
//  PrefDomainMultiValueItem.h
//  Board3
//
//  Created by Dror Kessler on 8/6/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefMultiValueItem.h"

@interface PrefDomainMultiValueItem : PrefMultiValueItem {
	
	NSString*	_domain;
	NSArray*	_roleSearchOrder;
	
	NSArray*	_prefixTitles;
	NSArray*	_prefixValues;

	NSArray*	_suffixTitles;
	NSArray*	_suffixValues;
	

}
@property (retain) NSString* domain;
@property (retain) NSArray* roleSearchOrder;

@property (retain) NSArray* prefixTitles;
@property (retain) NSArray* prefixValues;

@property (retain) NSArray* suffixTitles;
@property (retain) NSArray* suffixValues;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDomain:(NSString*)domain andDefaultValue:(NSString*)defaultValue;

@end
