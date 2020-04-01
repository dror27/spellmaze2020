//
//  PrefDomainDownloadItem.m
//  Board3
//
//  Created by Dror Kessler on 8/5/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefDomainDownloadItem.h"
#import "UserPrefs.h"
#import "ZipArchive.h"
#import "Folders.h"
#import "LanguageManager.h"
#import "StoreManager.h"
#import "PurchaseRecord.h"
#import "PrefUrlDirectorySection.h"
#import "ScoresDatabase.h"
#import "L.h"

extern time_t appStartedAt;

@interface PrefDomainDownloadItem (Privates)
-(void)doReportDidFinishOnMainThread:(NSError*)error;
@end


@implementation PrefDomainDownloadItem
@synthesize domain = _domain;
@synthesize url = _url;
@synthesize downloading = _downloading;
@synthesize fileCount = _fileCount;
@synthesize fileIndex = _fileIndex;
@synthesize receivedData = _receivedData;
@synthesize finished = _finished;
@synthesize finishedError = _finishedError;
@synthesize async = _async;
@synthesize asyncResponse = _asyncResponse;
@synthesize directoryUrl = _directoryUrl;
@synthesize directoryEntry = _directoryEntry;
@synthesize billingItem = _billingItem;
@synthesize purchaseRecord = _purchaseRecord;
@synthesize purchaseError = _purchaseError;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDomain:(NSString*)domain
{
	if ( self = [super initWithLabel:label andKey:key] )
	{
		self.domain = domain;
	}
	
	return self;
}

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andDomain:(NSString*)domain andURL:(NSURL*)url
{
	if ( self = [super initWithLabel:label andKey:NULL] )
	{
		self.key = key;
		self.domain = domain;
		self.url = url;
	}
	
	return self;
}

-(void)dealloc
{
	[_domain release];
	[_url release];
	[_receivedData release];
	[_finishedError release];
	[_asyncResponse release];
	[_directoryUrl release];
	[_directoryEntry release];
	[_billingItem release];
	[_purchaseRecord release];
	[_purchaseError release];
	
	[super dealloc];
}

-(BOOL)runAction
{
	// needs to do billing?
	PurchaseRecord*		purchaseRecord = [[StoreManager singleton] findOrCreatePurchaseRecordForBillingItem:_billingItem];
	if ( !purchaseRecord.purchasedAt )
	{
		// update status
		[self updateProgress:-1.0 withMessage:LOC(@"Purchasing ...")];
		
		// execute the purchase on the main thread
		self.purchaseRecord = nil;
		self.purchaseError = nil;
		[self performSelectorOnMainThread:@selector(doStartPurchase:) withObject:self waitUntilDone:TRUE];
		
		// wait for 10 minutes at the most
		for ( int n = 0 ; n < 600 ; n++ )
		{
			if ( _purchaseRecord )
				break;
			[NSThread sleepForTimeInterval:1.0];
		}
		
		// error?
		if ( _purchaseError )
		{
			// later: use specific information from NSError object
			[self updateProgress:-1.0 withMessage:LOC(@"Purchase Canceled")];	
			return FALSE;
		}
		
		// if here, item was purchased
	}
	else
		self.purchaseRecord = purchaseRecord;
	
	// common stuff
	NSNumberFormatter*		numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setGroupingSize:3];
	[numberFormatter setGroupingSeparator:@","];
	[numberFormatter setUsesGroupingSeparator:TRUE];
	
	// build url
	NSData*					data = NULL;
	NSError*				error;
	NSURL*					url = self.url ? self.url : [NSURL URLWithString:[UserPrefs getString:self.key withDefault:NULL]];
	url = [PrefUrlDirectorySection enrichDownloadUrl:url withAdditionalSuffix:[@"receipt=" stringByAppendingString:_purchaseRecord.purchaseReceipt]];
	
	// update purchase record with download information
	_purchaseRecord.directoryUrl = _directoryUrl;
	_purchaseRecord.directoryEntry = _directoryEntry;
	[[StoreManager singleton] addOrUpdatePurchaseRecord:_purchaseRecord];
	
	// nail to async for now
	self.async = TRUE;
	
	if ( self.async )
	{
		// alternative asynch implementation

		data = self.receivedData = [[[NSMutableData alloc] init] autorelease];
		self.finished = FALSE;
		self.finishedError = NULL;
		NSURLRequest*		request = [NSURLRequest requestWithURL:url 
												  cachePolicy:NSURLRequestUseProtocolCachePolicy
												timeoutInterval:60.0];
		
		[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_DOWNLOAD_START withTimeDelta:time(NULL) - appStartedAt];

	
		NSURLConnection*	connection = [NSURLConnection connectionWithRequest:request delegate:self];
		if ( !connection )
		{
			[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_DOWNLOAD_FAILED withTimeDelta:time(NULL) - appStartedAt];
			
			[self updateProgress:-1.0 withMessage:LOC(@"Connection Failed")];
			[self reportDidFinish:[[NSError alloc] init]];
			return FALSE;
		}
		else
		{
			[self updateProgress:-1.0 withMessage:LOC(@"Downloading ...")];
		
			while ( !self.finished ) 
			{
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
			}		
			
			if ( self.finishedError )
			{
				[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_DOWNLOAD_FAILED withTimeDelta:time(NULL) - appStartedAt];
				[self updateProgress:-1.0 withMessage:LOC(@"Connection Failed")];
				[self reportDidFinish:[[[NSError alloc] init] autorelease]];
				return FALSE;				
			}
			else
				[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_DOWNLOAD_OK withTimeDelta:time(NULL) - appStartedAt];

		}
	}
	else
	{
		// download file
		[self updateProgress:-1.0 withMessage:LOC(@"Downloading ...")];
		NSError*			error;
		NSURLResponse*		response;
		NSURL*				url = self.url ? self.url : [NSURL URLWithString:[UserPrefs getString:self.key withDefault:NULL]];
		NSURLRequest*		request = [NSURLRequest requestWithURL:url];
		data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	}

	NSNumber*			number = [NSNumber numberWithInt:[data length]];
	[self updateProgress:-1.0 withMessage:[NSString stringWithFormat:LOC(@"Downloaded %@ Bytes"), [numberFormatter stringFromNumber:number]]];

	// write to temp file
	[self updateProgress:-1.0 withMessage:LOC(@"Writing ... ")];
	NSFileManager*		fileManager = [NSFileManager defaultManager];
	NSString*			tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download.zip"];
	NSLog(@"tempPath: %@", tempPath);
	[fileManager createFileAtPath:tempPath contents:data attributes:nil];
	[self updateProgress:-1.0 withMessage:[NSString stringWithFormat:LOC(@"Wrote %@ Bytes"), [numberFormatter stringFromNumber:number]]];
	
	// establish target folder, in temp for now
	NSString*			targetPath = [Folders roleFolder:FolderRoleDownload forDomain:self.domain];
	NSLog(@"targetPath: %@", targetPath);
	[fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:TRUE attributes:nil error:&error];
	
	[Folders clearDomainCache:self.domain];
	if ( [self.domain isEqualToString:DF_LANGUAGES] )
		[LanguageManager clearLanguagesCache];
	
	// unzip
	[self updateProgress:-1.0 withMessage:LOC(@"Unpacking ...")];
	ZipArchive*			zipArchive = [[[ZipArchive alloc] init] autorelease];
	zipArchive.delegate = self;
	zipArchive.cleanFolders = TRUE;
	BOOL				result;
	result = [zipArchive UnzipOpenFile:tempPath];
	if ( !result )
	{
		[self updateProgress:-1.0 withMessage:LOC(@"Unpacking (open 2) Error")];
		return FALSE;
	}
	self.fileCount = [zipArchive UnzipCountFiles];
	self.fileIndex = 0;
	result = [zipArchive UnzipFileTo:targetPath overWrite:TRUE];
	if ( !result )
	{
		[self updateProgress:-1.0 withMessage:LOC(@"Unpacking (open 1) Error")];
		return FALSE;
	}
	result = [zipArchive UnzipCloseFile];
	if ( !result )
	{
		[self updateProgress:-1.0 withMessage:LOC(@"Unpacking (open 3) Error")];
		return FALSE;
	}
	
	// delete temp file
	[fileManager removeItemAtPath:tempPath error:&error];
	
	// save download status in purchase record
	_purchaseRecord.downloadedAt = [NSDate date];
	_purchaseRecord.downloadUrl = url;
	_purchaseRecord.leadingItemFolder = [targetPath stringByAppendingPathComponent:[[_purchaseRecord directoryEntry] objectForKey:@"leading-uuid"]];
	[[StoreManager singleton] addOrUpdatePurchaseRecord:_purchaseRecord];
	
	[self updateProgress:1.0 withMessage:LOC(@"Completed")];
	[self reportDidFinish:NULL];
	
	return FALSE;
}

-(void)zipArchive:(ZipArchive*)zipArchive processingFile:(NSString*)file
{
	self.fileIndex++;
	[self updateProgress:(self.fileIndex * 1.0 / self.fileCount) withMessage:LOC(@"Unpacking ...")];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
#ifdef DUMP
	NSLog(@"didReceiveResponse");
#endif
	
	self.asyncResponse = response;
    [self.receivedData setLength:0];	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];	
	
	if ( [self.asyncResponse expectedContentLength] )
	{
		float		progress = (float)[self.receivedData length] / [self.asyncResponse expectedContentLength];
	
		[self updateProgress:progress withMessage:LOC(@"Downloading ...")];
	}
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{	
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	self.finishedError = error;
	self.finished = TRUE;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);

	self.finished = TRUE;
}

-(void)doReportDidFinishOnMainThread:(NSError*)error
{
	[self performSelectorOnMainThread:@selector(reportDidFinish:) withObject:error waitUntilDone:FALSE];
}

-(void)doStartPurchase:(id)sender
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_PURCHASE_START withTimeDelta:time(NULL) - appStartedAt];
	
	// this is running on main thread ...
	id<StoreImplementation>		store = [[StoreManager singleton] storeForBillingItem:_billingItem];
	[store purchase:_billingItem withDelegate:self];
}

-(void)store:(id<StoreImplementation>)store didPurchase:(PurchaseRecord*)pr
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_PURCHASE_OK withTimeDelta:time(NULL) - appStartedAt];

	self.purchaseRecord = pr;
}

-(void)store:(id<StoreImplementation>)store purchaseFailed:(PurchaseRecord*)pr withError:(NSError*)error
{
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_PURCHASE_FAILED withTimeDelta:time(NULL) - appStartedAt];
	
	self.purchaseError = error;
	self.purchaseRecord = pr;		// must be last since we are spinning on it
}


@end
