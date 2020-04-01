//
//  PrefSwitchItem.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefItemBase.h"

@interface PrefBooleanItem : PrefItemBase {

	BOOL	_defaultValue;
}
@property BOOL defaultValue;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDefaultBooleanValue:(BOOL)defaultValue;
@end
