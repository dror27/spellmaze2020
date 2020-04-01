//
//  PrefStringItem.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PrefItemBase.h"
#import "StringTransformer.h"

@interface PrefStringItem : PrefItemBase {
	
	NSString*	_defaultValue;
	NSString*	_value;
	
	UIKeyboardType	_keyboardType;
	UITextAutocapitalizationType _autocapitalizationType;
	BOOL			_multiline;
	id<StringTransformer> _stringTransformer;
}
@property (retain) NSString* defaultValue;
@property (retain) NSString* value;
@property UIKeyboardType keyboardType;
@property UITextAutocapitalizationType autocapitalizationType;
@property BOOL multiline;
@property (retain) id<StringTransformer> stringTransformer;


-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDefaultStringValue:(NSString*)defaultValue;


@end
