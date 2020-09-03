//
//  PrefUrlDirectorySection.h
//  Board3
//
//  Created by Dror Kessler on 8/13/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefSection.h"
#import "StoreManager.h"

@protocol PrefUrlDirectoryDelegate;
@interface PrefUrlDirectorySection : PrefSection<StoreQuoteDelegate> {

	NSURL*							_url;
	id<PrefUrlDirectoryDelegate>	_delegate;
	id								_context;
	NSMutableSet*					_delegatesStore;
	NSDictionary*					_billingPageItems;
	
	NSString*						_limitToItemUUID;
}
@property (retain) NSURL* url;
@property (nonatomic,assign) id<PrefUrlDirectoryDelegate> delegate;
@property (retain) id context;
@property (retain) NSMutableSet* delegatesStore;
@property (retain) NSDictionary* billingPageItems;
@property (retain) NSString* limitToItemUUID;

+(NSURL*)enrichDownloadUrl:(NSURL*)url withAdditionalSuffix:(NSString*)additionalSuffix;
-(id)initWithURL:(NSURL*)url;

@end


@protocol PrefUrlDirectoryDelegate <NSObject>
-(void)urlDirectoryDidDownload:(NSString*)uuid withContext:(id)context;
@end

