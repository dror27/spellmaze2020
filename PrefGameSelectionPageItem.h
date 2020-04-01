//
//  PrefGameSelectionPageItem.h
//  Board3
//
//  Created by Dror Kessler on 8/31/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefPageItem.h"

@interface PrefGameSelectionPageItem : PrefPageItem {

	NSString*	_gameKey;
	NSString*	_languageKey;
	NSString*	_labelFormat;
}

@property (retain) NSString* gameKey;
@property (retain) NSString* languageKey;
@property (retain) NSString* labelFormat;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andPage:(PrefPage*)page
		andGameKey:(NSString*)gameKey andLanguageKey:(NSString*)languageKey andLabelFormat:(NSString*)labelFormat;
@end
