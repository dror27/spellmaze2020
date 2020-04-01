//
//  PurchaseRecord.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	
	PurchaseRecordStateInitialized = 0,
	PurchaseRecordStateQuoted,
	PurchaseRecordStatePurchased,
	PurchaseRecordStateDownloaded,
	PurchaseRecordStateMissing,
	PurchaseRecordStateOutdated
} PurchaseRecordState;


@interface PurchaseRecord : NSObject {

	NSString*		_uuid;			// of the purchase record itself
	
	NSString*		_billingItem;	// the id of the things being purchased
	
	NSString*		_billingCode;	// the billing code of the item that was actually purchased
	NSString*		_billingName;	// name of item in billing system
	NSString*		_billingDesc;	// description of item in billing system
	NSString*		_billingPrice;	// price of item in billing system
	
	NSURL*			_directoryUrl;	// the for the directory where this item was (to be) found
	NSDictionary*	_directoryEntry;// the the entry in the directory of this item	
	NSDictionary*	_updatedEntry;	// the entry pending update
	
	NSDate*			_quotedAt;		// time was quoted
	NSDate*			_purchasedAt;	// time was purchased
	NSDate*			_downloadedAt;	// time was downloaded
	NSDate*			_checkedForUpdatesAt; // time was checked for updates
	
	NSString*		_purchaseReceipt; // receipt/token received from store upon purchasing
	NSURL*			_downloadUrl;	// the url from which the item was downloaded
	
	NSString*		_leadingItemFolder; // folder where the leading item is stored (used to figure out if missing)
}
@property (retain) NSString* uuid;
@property (retain) NSString* billingItem;
@property (retain) NSString* billingCode;
@property (retain) NSString* billingName;
@property (retain) NSString* billingDesc;
@property (retain) NSString* billingPrice;
@property (retain) NSURL* directoryUrl;
@property (retain) NSDictionary* directoryEntry;
@property (retain) NSDictionary* updatedEntry;
@property (retain) NSDate* quotedAt;
@property (retain) NSDate* purchasedAt;
@property (retain) NSDate* downloadedAt;
@property (retain) NSDate* checkedForUpdatesAt;
@property (retain) NSString* purchaseReceipt;
@property (retain) NSURL* downloadUrl;
@property (retain) NSString* leadingItemFolder;

@property (readonly) float itemVersion;
@property (readonly) float itemUpdatedVersion;

+(PurchaseRecord*)recordForBillingItem:(NSString*)billingItem;

-(id)initWithDictionary:(NSDictionary*)dict;
-(NSDictionary*)dictionaryRepresentation;

-(NSString*)displayName;
-(PurchaseRecordState)calculatedState;
-(BOOL)missing;
-(NSString*)naturalBillingCode;
-(BOOL)checkForUpdates;
@end
