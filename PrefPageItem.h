//
//  PrefPageItem.h
//  Board3
//
//  Created by Dror Kessler on 8/3/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefItemBase.h"

@class PrefPage;
@interface PrefPageItem : PrefItemBase {

	PrefPage*		_page;
	NSString*		_viewControllerClassName;
	NSObject*		_viewControllerArgument;
	
	float			valueFieldWidthFactor;
}
@property (retain) PrefPage* page;
@property (retain) NSString* viewControllerClassName;
@property (retain) NSObject* viewControllerArgument;
@property float valueFieldWidthFactor;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andPage:(PrefPage*)page;

@end
