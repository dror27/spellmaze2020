//
//  PrefUUIDActionItem.h
//  Board3
//
//  Created by Dror Kessler on 8/20/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefThreadedActionItem.h"

@interface PrefUUIDActionItem : PrefThreadedActionItem {

	NSString*		_uuid;
	NSString*		_domain;
	NSString*		_actionScript;
	NSString*		_param;
	
	BOOL			startup;
}

@property (retain) NSString* uuid;
@property (retain) NSString* domain;
@property (retain) NSString* actionScript;
@property (retain) NSString* param;
@property BOOL startup;

-(NSString*)createUUID;
@end
