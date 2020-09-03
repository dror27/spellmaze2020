//
//  PrefDomainDirectoryListingMultiValueItem.h
//  Board3
//
//  Created by Dror Kessler on 8/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefMultiValueItem.h"

@interface PrefDomainDirectoryListingMultiValueItem : PrefMultiValueItem {

	NSURL*		_url;
	NSArray*	_directory;			// of NSDictionary
}
@property (retain) NSURL* url;
@property (retain) NSArray* directory;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andUrl:(NSURL*)url;

@end
