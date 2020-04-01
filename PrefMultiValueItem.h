//
//  PrefMultiValueItem.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefItemBase.h"
#import "PrefPage.h"


@class PrefSection;
@interface PrefMultiValueItem : PrefItemBase {

	NSString*		_defaultValue;
	NSArray*		_titles;
	NSArray*		_values;
	NSArray*		_props;
	NSString*		_value;
	
	PrefSection*	_moreSection;
	
	BOOL			emptyValueIsNull;
}
@property (retain) NSString* defaultValue;
@property (retain) NSArray* titles;
@property (retain) NSArray* values;
@property (retain) NSArray* props;
@property (retain) NSString* value;
@property (retain) PrefSection* moreSection;
@property BOOL emptyValueIsNull;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andTitles:(NSArray*)titles andValues:(NSArray*)values andDefaultStringValue:(NSString*)defaultValue;

-(BOOL)detailExistsForValue:(NSString*)value;
-(PrefPage*)detailForValue:(NSString*)value;
@end
