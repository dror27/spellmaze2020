//
//  PrefUrlDirectorySection.m
//  Board3
//
//  Created by Dror Kessler on 8/13/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefUrlDirectorySection.h"
#import "PrefSection.h"
#import "PrefPageItem.h"
#import "PrefPage.h"
#import "PrefDomainDownloadItem.h"
#import "PrefImageItem.h"
#import "UserPrefs.h"
#import "PrefFileActionDelegate.h"
#import "NSDictionary_TypedAccess.h"
#import "PrefLabelItem.h"
#import "SystemUtils.h"
#import "UUIDUtils.h"
#import "StoreManager.h"
#import "PrefRichPageItem.h"
#import "BrandManager.h"
#import "Folders.h"
#import "ScoresViewController.h"
#import "ScoresDatabase.h"
#import "L.h"

extern time_t		appStartedAt;


//#define	DUMP

@interface PrefUrlDirectorySection_ItemDelegate : PrefFileActionDelegate 
{
	id<PrefUrlDirectoryDelegate>	_delegate;
	id								_context;
	NSString*						_uuid;
}
@property (nonatomic,assign) id<PrefUrlDirectoryDelegate> delegate;
@property (retain) id context;
@property (retain) NSString* uuid;
@end
@implementation PrefUrlDirectorySection_ItemDelegate
@synthesize delegate = _delegate;
@synthesize context = _context;
@synthesize uuid = _uuid;

-(void)dealloc
{
	[_context release];
	[_uuid release];
	
	[super dealloc];
}

-(void)prefActionItem:(PrefActionItem*)item didFinish:(BOOL)success
{
	[super prefActionItem:item didFinish:success];
	
	if ( self.delegate )
		[self.delegate urlDirectoryDidDownload:self.uuid withContext:self.context];
	
	// make sure as realize a change in the current domain entity
	if ( !_context && [item isKindOfClass:[PrefDomainDownloadItem class]] )
	{
		PrefDomainDownloadItem*		ddlItem = (PrefDomainDownloadItem*)item;
		NSString*					leadingItemUUID = [[ddlItem directoryEntry] objectForKey:@"leading-uuid"];
		
		[Folders reportUUIDUpdated:leadingItemUUID withDomain:ddlItem.domain];

		[self performSelectorOnMainThread:@selector(popViewControllerAnimatedForItem:) withObject:item waitUntilDone:FALSE];
	}
}

-(void)popViewControllerAnimatedForItem:(PrefActionItem*)item
{
	// always called on main thread
	[item.viewController.navigationController popViewControllerAnimated:TRUE];
}

@end


@interface PrefUrlDirectorySection (Privates)
+(NSString*)removeParams:(NSString*)paramsString fromQuery:(NSString*)query;
@end


@implementation PrefUrlDirectorySection
@synthesize url = _url;
@synthesize delegate = _delegate;
@synthesize context = _context;
@synthesize delegatesStore = _delegatesStore;
@synthesize billingPageItems = _billingPageItems;
@synthesize limitToItemUUID = _limitToItemUUID;

-(void)dealloc
{
	[_url release];
	[_context release];
	[_delegatesStore release];
	[_billingPageItems release];
	[_limitToItemUUID release];
	
	[super dealloc];
}

-(id)initWithURL:(NSURL*)url
{
	if ( self = [super init] )
	{
		self.url = url;
		self.delegatesStore = [[[NSMutableSet alloc] init] autorelease];
	}
	return self;
}

-(void)doPullRequests:(NSDictionary*)props
{
	NSAutoreleasePool*		pool = [[NSAutoreleasePool alloc] init];
		
	[ScoresViewController executePullRequests:props];
	
	[pool release];
}

-(NSArray*)items
{
	float					softwareVersion = atof([[SystemUtils softwareVersion] UTF8String]);
	float					softwareBuild = atof([[SystemUtils softwareBuild] UTF8String]);
	NSString*				device = [UUIDUtils strip:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
	NSMutableDictionary*	billingPageItems = [NSMutableDictionary dictionary];
	
	if ( ![super items] )
	{
		[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_URL_DIR withTimeDelta:time(NULL) - appStartedAt];
		
		// fetch from url
		NSData*					data = [[[NSData alloc] initWithContentsOfURL:self.url] autorelease];
		NSString*				error;
		NSPropertyListFormat	format;
		NSDictionary*			props = [NSPropertyListSerialization propertyListFromData:data 
																 mutabilityOption:NSPropertyListImmutable 
																		   format:&format
																 errorDescription:&error];
		
		if ( [ScoresViewController executePullRequestsWorthLaunching:props] )
			[SystemUtils threadWithTarget:self selector:@selector(doPullRequests:) object:props];
		
		NSArray*				directoryItems = [props objectForKey:@"items"];
		NSMutableArray*			items = [[[NSMutableArray alloc] init] autorelease];
		for ( NSDictionary* directoryItem in directoryItems )
		{
			NSString*			type = [directoryItem objectForKey:@"type"];
			NSString*			name = [directoryItem objectForKey:@"name"];
			NSURL*				url = [NSURL URLWithString:[directoryItem objectForKey:@"url"] relativeToURL:self.url];
			NSString*			comment = [directoryItem objectForKey:@"comment"];
			
			// version check
			NSString*			minVersion = [directoryItem objectForKey:@"min-version"];
			if ( minVersion && softwareVersion < atof([minVersion UTF8String]) )
			{
#ifdef DUMP
				NSLog(@"[%@] ignore on minVersion", name);
#endif
				continue;
			}
			NSString*			maxVersion = [directoryItem objectForKey:@"max-version"];
			if ( maxVersion && softwareVersion > atof([maxVersion UTF8String]) )
			{
#ifdef DUMP
				NSLog(@"[%@] ignore on maxVersion", name);
#endif
				continue;
			}
			
			// build check
			NSString*			minBuild = [directoryItem objectForKey:@"min-build"];
			if ( minBuild && softwareBuild < atof([minBuild UTF8String]) )
			{
#ifdef DUMP
				NSLog(@"[%@] ignore on minBuild", name);
#endif
				continue;
			}
			NSString*			maxBuild = [directoryItem objectForKey:@"max-build"];
			if ( maxBuild && softwareBuild > atof([maxBuild UTF8String]) )
			{
#ifdef DUMP
				NSLog(@"[%@] ignore on maxBuild", name);
#endif
				continue;
			}
			
			// devices check
			NSArray*			devices = [directoryItem objectForKey:@"devices"];
			if ( devices && ![devices containsObject:device] )
			{
#ifdef DUMP
				NSLog(@"[%@] ignore on devices", name);
#endif
				continue;
			}
			
			// check item limitations
			if ( _limitToItemUUID )
				if ( ![_limitToItemUUID isEqualToString:[directoryItem objectForKey:@"uuid"]] )
				{
#ifdef DUMP
					NSLog(@"[%@] ignore on _limitToItemUUID", name);
#endif
					continue;					
				}
			
			// build icon
			NSURL*			itemIconUrl = nil;
			if ( [directoryItem hasKey:@"item-icon"] )
			{
				itemIconUrl = [NSURL URLWithString:[directoryItem objectForKey:@"item-icon"] relativeToURL:self.url];
			}
			
			if ( [type isEqualToString:@"directory"] )
			{
				// append version/build to url
				url = [PrefUrlDirectorySection enrichDownloadUrl:url withAdditionalSuffix:nil];
				
				// point to another directory
				PrefPage*					page = [[[PrefPage alloc] init] autorelease];
				PrefUrlDirectorySection*	section = [[[PrefUrlDirectorySection alloc] initWithURL:url] autorelease];
				section.comment = comment;
				section.delegate = self.delegate;
				section.context = self.context;
				page.title = name;
				page.sections = [NSArray arrayWithObject:section];

				PrefRichPageItem*			item = [[[PrefRichPageItem alloc] initWithLabel:NULL andKey:NULL andPage:page] autorelease];
				item.title = name;
				item.subtitle = comment;
				item.iconUrl = itemIconUrl;
				
				[items addObject:item];
			}
			else if ( [type isEqualToString:@"item"] )
			{
				// extract billing item and code
				NSString*			billingItem = [directoryItem objectForKey:@"uuid"];
				NSString*			billingCode = [directoryItem objectForKey:@"billing-code"];
				if ( !billingCode )
					billingCode = [@"com.spellmaze.generic." stringByAppendingString:billingItem];
				
				PurchaseRecord*		pr = [[StoreManager singleton] findOrCreatePurchaseRecordForBillingItem:billingItem];
				pr.billingCode = billingCode;
				pr.billingItem = billingItem;
				pr.directoryUrl = self.url;
				pr.directoryEntry = directoryItem;
				[[StoreManager singleton] addOrUpdatePurchaseRecord:pr];
				
				
				// point to an item download/update
				PrefUrlDirectorySection_ItemDelegate*		delegate = [[[PrefUrlDirectorySection_ItemDelegate alloc] init] autorelease];
				[_delegatesStore addObject:delegate];
				delegate.props = [NSDictionary dictionaryWithDictionary:directoryItem];
				delegate.billingItem = billingItem;

				if ( !_limitToItemUUID && ![delegate shouldDownload] )
					continue;
				
				delegate.delegate = self.delegate;
				delegate.context = self.context;
				delegate.uuid = [directoryItem stringForKey:@"leading-uuid" withDefaultValue:NULL];

				NSString*					iconUrlString = [directoryItem objectForKey:@"icon"];
				NSURL*						icon = !iconUrlString ? NULL : [NSURL URLWithString:iconUrlString relativeToURL:url];
				NSString*					domain = [directoryItem objectForKey:@"domain"];
				PrefPage*					page = [[[PrefPage alloc] init] autorelease];
				PrefSection*				infoSection = [[[PrefSection alloc] init] autorelease];
				infoSection.items = [NSArray arrayWithObjects:
									 !icon ? NULL : [[PrefImageItem alloc] initWithLabel:@"" andKey:NULL andImageURL:icon],
									NULL
									];
				infoSection.comment = comment;
				
				/*
				PrefSection*				billingSection = [[[PrefSection alloc] init] autorelease];
				billingSection.items = [NSArray array];
				billingSection.comment = @"Fetching Billing Information ....";
				*/
				
				PrefSection*				downloadSection = [[[PrefSection alloc] init] autorelease];
				PrefDomainDownloadItem*		downloadItem;
				downloadSection.items = [NSArray arrayWithObject:
										 downloadItem = [[[PrefDomainDownloadItem alloc] initWithLabel:@"Contacting Store ..." andKey:NULL andDomain:domain andURL:url] autorelease]];
				downloadItem.delegate = delegate;
				downloadItem.disabled = TRUE;
				downloadItem.directoryUrl = self.url;
				downloadItem.directoryEntry = directoryItem;
				downloadItem.billingItem = billingItem;
				
				
				page.title = name;
				page.sections = [NSArray arrayWithObjects:infoSection, /*billingSection, */downloadSection, NULL];
				
				PrefRichPageItem*			item = [[[PrefRichPageItem alloc] initWithLabel:NULL andKey:NULL andPage:page] autorelease];
				item.title = name;
				item.subtitle = comment;
				item.iconUrl = itemIconUrl;
				[items addObject:item];
				
				[billingPageItems setObject:item forKey:billingItem];
			}
		}

		if ( ![items count] )
		{
			[items addObject:[[PrefLabelItem alloc] initWithLabel:@"All Items Already Loaded" andKey:NULL]];
		}
		
		[super setItems:items];
	}
	
	// queue a quote?
	if ( [billingPageItems count] )
	{
		self.billingPageItems = billingPageItems;
		[self performSelector:@selector(doQuote:) withObject:self afterDelay:0.1];
	}
		
	return [super items];
}

-(void)doQuote:(id)sender
{
	NSArray*				billingItems = [_billingPageItems allKeys];
	NSMutableDictionary*	storeBillingItems = [NSMutableDictionary dictionary];
	StoreManager*			manager = [StoreManager singleton];
	
	// collect stores
	for ( NSString* billingItem in billingItems )
	{
		id<StoreImplementation>		store = [manager storeForBillingItem:billingItem];
		NSString*					storeKey = [manager storeKey:store];
		NSMutableArray*				items = [storeBillingItems objectForKey:storeKey];
		if ( !items )
		{
			items = [NSMutableArray array];
			[storeBillingItems setObject:items forKey:storeKey];
		}
		[items addObject:billingItem];
	}
	
	// execute quotes on stores
	for ( NSString* storeKey in [storeBillingItems allKeys] )
	{
		id<StoreImplementation>		store = [manager storeByKey:storeKey];
		[store quote:[storeBillingItems objectForKey:storeKey] withDelegate:self];
	}
}

-(void)store:(id<StoreImplementation>)store didQuote:(PurchaseRecord*)pr
{
#ifdef	DUMP
	NSLog(@"[PrefUrlDirectorySection] - didQuote: %@", pr.billingItem);	
	NSLog(@" -- Name: %@", pr.billingName);
	NSLog(@" -- Desc: %@", pr.billingDesc);
	NSLog(@" -- Price: %@", pr.billingPrice);
#endif
	
	// locate page item
	PrefPageItem*		item = [_billingPageItems objectForKey:pr.billingItem];
	if ( !item )
		return;
	
	// access its components
	PrefPage*				page = item.page;
	PrefSection*			infoSection = [[page sections] objectAtIndex:0];
	PrefSection*			downloadSection = [[page sections] objectAtIndex:1];
	PrefDomainDownloadItem*	downloadItem = [downloadSection.items objectAtIndex:0];
	
	// install fields
	if ( pr.billingName )
		page.title = pr.billingName;
	if ( pr.billingDesc )
		infoSection.comment = pr.billingDesc;
	
	// setup download label
	NSString*			label = LOC(@"Download");
	if ( !pr.purchasedAt )
	{
		// not purchased yet. change from Download only if not free
		if ( pr.billingPrice && ![pr.billingPrice isEqualToString:STORE_PRICE_FREE] )
			label = [NSString stringWithFormat:LOC(@"%@, Buy & Download"), pr.billingPrice];
	}
	else if ( pr.downloadedAt )
	{
		float						version = [downloadItem.directoryEntry floatForKey:@"version" withDefaultValue:-1.0];
		
		if ( version > pr.itemVersion )
			label = LOC(@"Update");
		else
			label = LOC(@"Restore");
	}
	downloadItem.label = label;
	downloadItem.disabled = FALSE;
}

-(void)store:(id<StoreImplementation>)store quoteFailed:(PurchaseRecord*)pr withError:(NSError*)error
{
	NSLog(@"[PrefUrlDirectorySection] - quoteFailed: %@, %@", pr.billingItem, error);
	
	// locate page item
	PrefPageItem*		item = [_billingPageItems objectForKey:pr.billingItem];
	if ( !item )
		return;
	
	// access its components
	PrefPage*				page = item.page;
	PrefSection*			downloadSection = [[page sections] objectAtIndex:1];
	PrefDomainDownloadItem*	downloadItem = [downloadSection.items objectAtIndex:0];
	
	// setup download label
	downloadItem.label = LOC(@"Not Available For Sale");
	downloadItem.disabled = TRUE;
	
}

+(NSURL*)enrichDownloadUrl:(NSURL*)url withAdditionalSuffix:(NSString*)additionalSuffix;
{
	// append version/build to url
	NSMutableString*			suffix = [NSMutableString stringWithFormat:@"ver=%@&build=%@&device=%@&identity=%@",
										  [SystemUtils softwareVersion], [SystemUtils softwareBuild], [[UIDevice currentDevice] identifierForVendor], [UserPrefs userIdentity]];
	NSString*					query = [url query];
	query = [PrefUrlDirectorySection removeParams:@"ver,build,device,identity" fromQuery:query];
	if ( query && [query length] )
		[suffix insertString:@"&" atIndex:0];
	else
		[suffix insertString:@"?" atIndex:0];
	
	if ( additionalSuffix )
	{
		[suffix appendString:@"&"];
		[suffix appendString:additionalSuffix];
	}
	
	// trim url from query string
	NSString*	urlNoQuery = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
	
	// build url by appending query and suffix
	NSMutableString*	newUrlString = [NSMutableString stringWithString:urlNoQuery];
	if ( query && [query length] )
	{
		[newUrlString appendString:@"?"];
		[newUrlString appendString:query];
	}
	[newUrlString appendString:suffix];
	
	return [NSURL URLWithString:newUrlString];
}

+(NSString*)removeParams:(NSString*)paramsString fromQuery:(NSString*)query
{
	if ( !query || ![query length] )
		return query;
	
	NSSet*				params = [NSSet setWithArray:[paramsString componentsSeparatedByString:@","]];
	
	NSMutableArray*		newComps = [NSMutableArray array];
	for ( NSString* comp in [query componentsSeparatedByString:@"&"] )
	{
		if ( ![params containsObject:[[comp componentsSeparatedByString:@"="] objectAtIndex:0]] )
			[newComps addObject:comp];
	}
	if ( [newComps count] )
		return [newComps componentsJoinedByString:@"&"];
	else
		return nil;
}

@end
