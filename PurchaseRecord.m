//
//  PurchaseRecord.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PurchaseRecord.h"
#import "NSDictionary_TypedAccess.h"
#import "UUIDUtils.h"
#import "Folders.h"
#import "PrefUrlDirectorySection.h"

//#define		DUMP_DICT

#define		NO_VERSION				(-1.0)

#define		KEY_UUID				@"uuid"
#define		KEY_BILLING_ITEM		@"billing-item"
#define		KEY_BILLING_CODE		@"billing-code"
#define		KEY_BILLING_NAME		@"billing-name"
#define		KEY_BILLING_DESC		@"billing-desc"
#define		KEY_BILLING_PRICE		@"billing-price"
#define		KEY_DIRECTORY_URL		@"directory-url"
#define		KEY_DIRECTORY_ENTRY		@"directory-entry"
#define		KEY_UPDATED_ENTRY		@"updated-entry"
#define		KEY_QUOTED_AT			@"quoted-at"
#define		KEY_PURCHASED_AT		@"purcahsed-at"
#define		KEY_DOWNLOADED_AT		@"downloaded-at"
#define		KEY_CHECKED_FOR_UPDATES_AT @"checked-for-updates-at"
#define		KEY_PURCHASE_RECEIPT	@"purchase-receipt"
#define		KEY_DOWNLOAD_URL		@"download-url"
#define		KEY_LEADING_ITEM_FOLDER	@"leading-item-folder"

#define		KEY_ENTRY_VERSION		@"version"


@implementation PurchaseRecord
@synthesize uuid = _uuid;
@synthesize billingItem = _billingItem;
@synthesize billingCode = _billingCode;
@synthesize billingName = _billingName;
@synthesize billingDesc = _billingDesc;
@synthesize billingPrice = _billingPrice;
@synthesize directoryUrl = _directoryUrl;
@synthesize directoryEntry = _directoryEntry;
@synthesize updatedEntry = _updatedEntry;
@synthesize quotedAt = _quotedAt;
@synthesize purchasedAt = _purchasedAt;
@synthesize downloadedAt = _downloadedAt;
@synthesize checkedForUpdatesAt = _checkedForUpdatesAt;
@synthesize purchaseReceipt = _purchaseReceipt;
@synthesize downloadUrl = _downloadUrl;
@synthesize leadingItemFolder = _leadingItemFolder;

+(PurchaseRecord*)recordForBillingItem:(NSString*)billingItem
{
	PurchaseRecord*		pr = [[[PurchaseRecord alloc] init] autorelease];
	
	pr.uuid = [UUIDUtils createUUID];
	pr.billingItem = billingItem;
	
	return pr;
}

-(id)initWithDictionary:(NSDictionary*)dict
{
	if ( self = [super init] )
	{
		self.uuid = [dict objectForKey:KEY_UUID];
		self.billingItem = [dict objectForKey:KEY_BILLING_ITEM];
		self.billingCode = [dict objectForKey:KEY_BILLING_CODE];
		self.billingName = [dict objectForKey:KEY_BILLING_NAME];
		self.billingDesc = [dict objectForKey:KEY_BILLING_DESC];
		self.billingPrice = [dict objectForKey:KEY_BILLING_PRICE];
		
		NSString*		s = [dict objectForKey:KEY_DIRECTORY_URL];
		if ( s )
			self.directoryUrl = [NSURL URLWithString:s];
		self.directoryEntry = [dict objectForKey:KEY_DIRECTORY_ENTRY];
		self.updatedEntry = [dict objectForKey:KEY_UPDATED_ENTRY];
		
		NSNumber*		n;
		n = [dict objectForKey:KEY_QUOTED_AT];
		if ( n )
			self.quotedAt = [NSDate dateWithTimeIntervalSince1970:[n longValue]];
		n = [dict objectForKey:KEY_PURCHASED_AT];
		if ( n )
			self.purchasedAt = [NSDate dateWithTimeIntervalSince1970:[n longValue]];
		n = [dict objectForKey:KEY_DOWNLOADED_AT];
		if ( n )
			self.downloadedAt = [NSDate dateWithTimeIntervalSince1970:[n longValue]];
		n = [dict objectForKey:KEY_CHECKED_FOR_UPDATES_AT];
		if ( n )
			self.checkedForUpdatesAt = [NSDate dateWithTimeIntervalSince1970:[n longValue]];
		
		self.purchaseReceipt = [dict objectForKey:KEY_PURCHASE_RECEIPT];
		s = [dict objectForKey:KEY_DOWNLOAD_URL];
		if ( s )
			self.downloadUrl = [NSURL URLWithString:s];
		
		self.leadingItemFolder = [dict objectForKey:KEY_LEADING_ITEM_FOLDER];
	}
	return self;
}

-(void)dealloc
{
	[_uuid release];
	[_billingItem release];
	[_billingCode release];
	[_billingName release];
	[_billingDesc release];
	[_billingPrice release];
	[_directoryUrl release];
	[_directoryEntry release];
	[_updatedEntry release];
	[_quotedAt release];
	[_purchasedAt release];
	[_downloadedAt release];
	[_checkedForUpdatesAt release];
	[_purchaseReceipt release];
	[_downloadUrl release];
	[_leadingItemFolder release];
	
	[super dealloc];
}

-(NSDictionary*)dictionaryRepresentation
{
	NSMutableDictionary*	dict = [NSMutableDictionary dictionary];
	
	if ( _uuid )
		[dict setObject:_uuid forKey:KEY_UUID];
	if ( _billingItem )
		[dict setObject:_billingItem forKey:KEY_BILLING_ITEM];
	if ( _billingCode )
		[dict setObject:_billingCode forKey:KEY_BILLING_CODE];
	if ( _billingName )
		[dict setObject:_billingName forKey:KEY_BILLING_NAME];
	if ( _billingDesc )
		[dict setObject:_billingDesc forKey:KEY_BILLING_DESC];
	if ( _billingPrice )
		[dict setObject:_billingPrice forKey:KEY_BILLING_PRICE];
	
	if ( _directoryUrl )
		[dict setObject:[_directoryUrl absoluteString] forKey:KEY_DIRECTORY_URL];
	if ( _directoryEntry )
		[dict setObject:_directoryEntry forKey:KEY_DIRECTORY_ENTRY];
	if ( _updatedEntry )
		[dict setObject:_updatedEntry forKey:KEY_UPDATED_ENTRY];
	
	if ( _quotedAt )
		[dict setObject:[NSNumber numberWithLong:[_quotedAt timeIntervalSince1970]] forKey:KEY_QUOTED_AT];
	if ( _purchasedAt )
		[dict setObject:[NSNumber numberWithLong:[_purchasedAt timeIntervalSince1970]] forKey:KEY_PURCHASED_AT];
	if ( _downloadedAt )
		[dict setObject:[NSNumber numberWithLong:[_downloadedAt timeIntervalSince1970]] forKey:KEY_DOWNLOADED_AT];
	if ( _checkedForUpdatesAt )
		[dict setObject:[NSNumber numberWithLong:[_checkedForUpdatesAt timeIntervalSince1970]] forKey:KEY_CHECKED_FOR_UPDATES_AT];
	
	if ( _purchaseReceipt )
		[dict setObject:_purchaseReceipt forKey:KEY_PURCHASE_RECEIPT];
	if ( _downloadUrl )
		[dict setObject:[_downloadUrl absoluteString] forKey:KEY_DOWNLOAD_URL];
	if ( _leadingItemFolder )
		[dict setObject:_leadingItemFolder forKey:KEY_LEADING_ITEM_FOLDER];

#ifdef DUMP_DICT
	{
		NSString*				errorString;
		NSData*					data = [NSPropertyListSerialization dataFromPropertyList:dict 
													format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
		NSLog(@"[PurchaseRecord] DUMP_DICT:\n%@", [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease]);
	}
#endif
	
	return dict;
}

-(float)itemVersion
{
	if ( _directoryEntry )
		return [_directoryEntry floatForKey:KEY_ENTRY_VERSION withDefaultValue:NO_VERSION];
	else
		return NO_VERSION;
}

-(float)itemUpdatedVersion
{
	if ( _updatedEntry )
		return [_updatedEntry floatForKey:KEY_ENTRY_VERSION withDefaultValue:NO_VERSION];
	else
		return NO_VERSION;	
}

-(NSString*)displayName
{
	if ( _billingName && [_billingName length] )
		return _billingName;
	if ( _directoryEntry && [_directoryEntry objectForKey:@"name"] )
		return [_directoryEntry objectForKey:@"name"];
	else
		return _billingItem;
}

-(PurchaseRecordState)calculatedState
{
	if ( _downloadedAt )
	{
		if ( [self missing] )
			return PurchaseRecordStateMissing;
		else if ( [self itemUpdatedVersion] > [self itemVersion] )
			return PurchaseRecordStateOutdated;
		else
			return PurchaseRecordStateDownloaded;
	}
	else if ( _purchasedAt )
		return PurchaseRecordStatePurchased;
	else if ( _quotedAt )
		return PurchaseRecordStateQuoted;
	else 
		return PurchaseRecordStateInitialized;
}

-(BOOL)missing
{
	BOOL		isMissing = FALSE;
	
	if ( _downloadedAt && _leadingItemFolder )
	{
		
		NSString*		domain = [_directoryEntry objectForKey:@"domain"];
		NSString*		leadingUUID = [_directoryEntry objectForKey:@"leading-uuid"];
		
		NSDictionary*	props = [Folders findUUIDProps:NULL forDomain:domain withUUID:leadingUUID];
		if ( ![props objectForKey:@"__baseFolder"] )
			isMissing = TRUE;
	}
			
	return isMissing;
}

-(NSString*)naturalBillingCode
{
	NSArray*	comps = [_billingCode componentsSeparatedByString:@":"];
	
	if ( [comps count] < 2 )
		return _billingCode;
	else
		return [comps objectAtIndex:1];
}

-(BOOL)checkForUpdates
{
	if ( _downloadedAt )
	{
		NSURL*					url = [PrefUrlDirectorySection enrichDownloadUrl:_directoryUrl withAdditionalSuffix:nil];
		NSData*					data = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
		NSString*				error;
		NSPropertyListFormat	format;
		NSDictionary*			props = [NSPropertyListSerialization propertyListFromData:data 
																 mutabilityOption:NSPropertyListImmutable 
																		   format:&format
																 errorDescription:&error];
		NSArray*				directoryItems = [props objectForKey:@"items"];
		for ( NSDictionary* directoryItem in directoryItems )
		{
			NSString*			uuid = [directoryItem objectForKey:@"uuid"];
			if ( [_billingItem isEqualToString:uuid] )
			{
				self.updatedEntry = directoryItem;
				self.checkedForUpdatesAt = [NSDate date];
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

@end
