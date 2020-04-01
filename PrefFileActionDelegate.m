//
//  PrefFileActionDelegate.m
//  Board3
//
//  Created by Dror Kessler on 8/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefFileActionDelegate.h"
#import "UserPrefs.h"
#import "NSDictionary_TypedAccess.h"
#import "StoreManager.h"
#import "RoleManager.h"
#import "L.h"

@interface PrefFileActionDelegate (Privates)
-(NSString*)key;
-(float)currentVersion;
-(float)newVersion;
-(BOOL)alwaysDownload;
@end


@implementation PrefFileActionDelegate
@synthesize props = _props;
@synthesize billingItem = _billingItem;

-(void)dealloc
{
	[_props release];
	[_billingItem release];
	
	[super dealloc];
}

-(BOOL)shouldDownload
{
	PurchaseRecordState	state = [[[StoreManager singleton] findOrCreatePurchaseRecordForBillingItem:_billingItem] calculatedState];
	if ( state != PurchaseRecordStateDownloaded )
		return TRUE;
	
	float	newVersion = [self newVersion];
	float	currentVersion = [self currentVersion];
	
	if ( newVersion < 0 || currentVersion < 0 || newVersion > currentVersion || [self alwaysDownload] )
		return TRUE;
	else
		return FALSE;
}

-(NSString*)downloadLabel
{
	float	currentVersion = [self currentVersion];

	return (currentVersion < 0.0) ? LOC(@"Download") : LOC(@"Update");
}

-(void)prefActionItem:(PrefActionItem*)item didFinish:(BOOL)success
{
	if ( success )
		[UserPrefs setDictionary:[self key] withValue:self.props];
}
		 
-(NSString*)key
{
	return [NSString stringWithFormat:@"_downloaded_%@", [self.props stringForKey:@"uuid" withDefaultValue:@""]];
}

-(float)newVersion
{
	return [self.props floatForKey:@"version" withDefaultValue:-1.0];
}

-(float)currentVersion
{
	PurchaseRecord*		pr = [[StoreManager singleton] findOrCreatePurchaseRecordForBillingItem:_billingItem];
	
	
	return pr.itemVersion;
}

-(BOOL)alwaysDownload
{
	return CHEAT_ON(CHEAT_IGNORE_DOWNLOAD_VERSIONS);
}

@end
