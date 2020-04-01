//
//  PrefDomainDownloadItem.h
//  Board3
//
//  Created by Dror Kessler on 8/5/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreManager.h"

#import "PrefThreadedActionItem.h"

@interface PrefDomainDownloadItem : PrefThreadedActionItem<StorePurchaseDelegate> {

	NSString*		_domain;
	NSURL*			_url;
	BOOL			_downloading;
	int				_fileCount;
	int				_fileIndex;
	
	NSMutableData*	_receivedData;
	BOOL			_finished;
	NSError*		_finishedError;
	BOOL			_async;
	NSURLResponse*	_asyncResponse;
	
	NSURL*			_directoryUrl;
	NSDictionary*	_directoryEntry;
	NSString*		_billingItem;
	
	PurchaseRecord*	_purchaseRecord;
	NSError*		_purchaseError;
	
}
@property (retain) NSString* domain;
@property (retain) NSURL* url;
@property BOOL downloading;
@property int fileCount;
@property int fileIndex;
@property (retain) NSMutableData* receivedData;
@property BOOL finished;
@property (retain) NSError* finishedError;
@property BOOL async;
@property (retain) NSURLResponse* asyncResponse;
@property (retain) NSURL* directoryUrl;
@property (retain) NSDictionary* directoryEntry;
@property (retain) NSString* billingItem;
@property (retain) PurchaseRecord* purchaseRecord;
@property (retain) NSError* purchaseError;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDomain:(NSString*)domain;
-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDomain:(NSString*)domain andURL:(NSURL*)url;


@end
