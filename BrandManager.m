//
//  BrandManager.m
//  Board3
//
//  Created by Dror Kessler on 8/14/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "BrandManager.h"
#import "UserPrefs.h"

extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"BrandManager_singleton"




@interface BrandManager (Privates)
-(void)loadBrand;
@end


@implementation BrandManager
@synthesize currentBrand = _currentBrand;
@synthesize delegates = _delegates;

-(id)init
{
	if ( self = [super init] )
	{
		self.delegates = [[[NSMutableSet alloc] init] autorelease];
		[self loadBrand];
		[UserPrefs addKeyDelegate:self forKey:PK_BRAND];
	}
	return self;
}

-(void)dealloc
{
	[_currentBrand release];
	[_delegates release];
	
	[super dealloc];
}

+(BrandManager*)singleton
{
	@synchronized ([BrandManager class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[BrandManager alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

+(Brand*)currentBrand
{
	return [[BrandManager singleton] currentBrand];
}

-(void)addDelegate:(id<BrandManagerDelegate>)delegate
{
	[_delegates addObject:delegate];
	
	// compensate for the 'retain' executed by the addObject: selector. this is a weak reference array!
	[delegate autorelease];
}

-(void)removeDelegate:(id<BrandManagerDelegate>)delegate
{
	if ( [_delegates containsObject:delegate] )
	{
		// compensate for the 'release' executed by the addObject: selector. this is a week reference array!
		[delegate retain];
	
		[_delegates removeObject:delegate];
	}
}


-(void)userPrefsKeyChanged:(NSString*)key
{
	[self loadBrand];
}

-(void)loadBrand
{
	self.currentBrand = [[[Brand alloc] initWithUUID:[UserPrefs getString:PK_BRAND withDefault:BM_DEFAULT_BRAND]] autorelease];
	
	for ( id<BrandManagerDelegate> delegate in [NSSet setWithSet:_delegates] )
		[delegate brandDidChange:_currentBrand];
}

@end
