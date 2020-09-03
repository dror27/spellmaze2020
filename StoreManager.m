//
//  StoreManager.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/27/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "StoreManager.h"
#import "UserPrefs.h"
#import "FreeStore.h"
#import "AppleStore.h"
#import "RoleManager.h"
#import "NSDictionary_TypedAccess.h"
#import "Folders.h"
#import "ScoresDatabase.h"

extern time_t		appStartedAt;


extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"StoreManager_singleton"

#define	FREE_STORE_KEY		@"FS"
#define	APPLE_STORE_KEY		@"AS"

//#define	DUMP

@interface StoreManager (Privates)
-(NSDictionary*)loadPurchaseRecords;
-(NSMutableDictionary*)loadMutablePurchaseRecords;
-(void)savePurchaseRecords:(NSDictionary*)dict;
-(void)initPurchaseRecords;
@end

@implementation StoreManager
@synthesize stores = _stores;

+(StoreManager*)singleton
{
	@synchronized ([StoreManager class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[StoreManager alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(id)init
{
	if ( self = [super init] )
	{
		self.stores = [NSDictionary dictionaryWithObjectsAndKeys:
								[[[FreeStore alloc] initWithStoreManager:self] autorelease],
								FREE_STORE_KEY,
								[[[AppleStore alloc] initWithStoreManager:self] autorelease],
								APPLE_STORE_KEY,
					   nil];		
		
		[self initPurchaseRecords];
	}
	return self;
}

-(id<StoreImplementation>)storeForBillingItem:(NSString*)billingItem
{
	BOOL				useFree = FALSE;
	PurchaseRecord*		pr = [self findOrCreatePurchaseRecordForBillingItem:billingItem];
	NSString*			billingCode = [pr billingCode];
	
#if TARGET_IPHONE_SIMULATOR
	useFree = TRUE;
#endif
	NSString*	key;

	if ( useFree || CHEAT_ON(CHEAT_USE_FREE_STORE_ALWAYS) )
	{
		key = FREE_STORE_KEY;
	}
	else if ( CHEAT_ON(CHEAT_USE_APPLE_STORE_ALWAYS) )
	{
		key = APPLE_STORE_KEY;
	}
	else
	{
		// find out from billing code
		NSArray*	comps = [billingCode componentsSeparatedByString:@":"];
		if ( [comps count] > 1 )
			key = [comps objectAtIndex:0];
		else
			key = APPLE_STORE_KEY;
	}
	
	return [self storeByKey:key];
}

-(id<StoreImplementation>)storeByKey:(NSString*)storeKey
{
	if ( ![_stores hasKey:storeKey] )
	{
		// can not find appropriate store!
		NSLog(@"ERROR - no store for %@", storeKey);
		return nil;
	}
	else
		return [_stores objectForKey:storeKey];	
}

-(NSString*)storeKey:(id<StoreImplementation>)store
{
	for ( NSString* key in [_stores allKeys] )
		if ( [_stores objectForKey:key] == store )
			return key;
	
	return nil;
}

-(void)dealloc
{
	[_stores release];
	
	[super dealloc];
}

-(void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
#ifdef DUMP
	NSLog(@"[productsRequest:didReceiveResponse:] - request=%@", request);
	NSLog(@"[productsRequest:didReceiveResponse:] - response=%@", response);

	NSLog(@"[productsRequest:didReceiveResponse:] - products=%@", response.products);
	NSLog(@"[productsRequest:didReceiveResponse:] - invalidProductIdentifiers=%@", response.invalidProductIdentifiers);
#endif
	
    [request autorelease];
	
}

-(NSArray*)allPurchaseRecords
{
	NSMutableArray*	all = [NSMutableArray array];
	
	for ( NSDictionary* dictElem in [[self loadPurchaseRecords] allValues] )
		[all addObject:[[[PurchaseRecord alloc] initWithDictionary:dictElem] autorelease]];
	
	return all;
}

-(PurchaseRecord*)findOrCreatePurchaseRecordForBillingItem:(NSString*)billingItem
{
	NSDictionary*		dict = [self loadPurchaseRecords];
	NSDictionary*		dictElem = [dict objectForKey:billingItem];
	
	if ( !dictElem )
		return [PurchaseRecord recordForBillingItem:billingItem];
	else
		return [[[PurchaseRecord alloc] initWithDictionary:dictElem] autorelease];
}

-(void)addOrUpdatePurchaseRecord:(PurchaseRecord*)pr
{
	NSMutableDictionary*	dict = [self loadMutablePurchaseRecords];
	
	[dict setObject:[pr dictionaryRepresentation] forKey:[pr billingItem]];
	
	[self savePurchaseRecords:dict];
}

-(NSDictionary*)loadPurchaseRecords
{
	return [UserPrefs getDictionary:PREF_KEY_PURCHASE_RECORDS withDefault:[NSDictionary dictionary]];
}

-(NSMutableDictionary*)loadMutablePurchaseRecords
{
	return [NSMutableDictionary dictionaryWithDictionary:[self loadPurchaseRecords]];
}

-(void)savePurchaseRecords:(NSDictionary*)dict
{
	[UserPrefs setDictionary:PREF_KEY_PURCHASE_RECORDS withValue:dict];
}

-(void)initPurchaseRecords
{
	NSDate*				now = [NSDate date];
	
	// for all domain records which don't have a purchase record, try to create one from the update-record.plist 
	for ( NSString* domain in [NSArray arrayWithObjects:DF_LANGUAGES, DF_LEVELS, DF_GAMES, DF_GAMES, DF_BRANDS, DF_CATALOGS, nil] )
		for ( NSString* folder in [Folders listUUIDSubFolders:NULL forDomain:domain] )
		{
			// get billing item (escape of no update record to begin with - all downloaded items will not have such - only items that came with the application (builtin)
			NSMutableDictionary*	updateRecord = [Folders getMutableFolderProps:folder withPropsFilename:@"update-record.plist" returnDefaultIfNotPresent:FALSE];
			if ( !updateRecord )
				continue;
			NSString*				billingItem = [updateRecord objectForKey:@"directory-entry/uuid" withDefaultValue:nil];
			if ( !billingItem )
				continue;
			
			// has billing item, see if not already have purchase record which is marked as downloaded
			PurchaseRecord*			pr = [self findOrCreatePurchaseRecordForBillingItem:billingItem];
			if ( pr.downloadedAt )
				continue;
			
			// update it, mark as downloaded
			pr.directoryEntry = [updateRecord objectForKey:@"directory-entry"];
			pr.directoryUrl = [NSURL URLWithString:[updateRecord objectForKey:@"directory-url"]];
			pr.downloadedAt = now;	// mark it as having been downloaded
			[self addOrUpdatePurchaseRecord:pr];
		}
}

@end
