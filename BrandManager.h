//
//  BrandManager.h
//  Board3
//
//  Created by Dror Kessler on 8/14/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brand.h"
#import "UserPrefs.h"

#define	BM_DEFAULT_BRAND		@"86D1C949-9B24-C931-E5B5-BBAF94B06901"

@protocol BrandManagerDelegate<NSObject>
-(void)brandDidChange:(Brand*)brand;
@end


@interface BrandManager : NSObject<UserPrefsDelegate> {

	Brand*				_currentBrand;
	NSMutableSet*		_delegates;
}
@property (retain) Brand* currentBrand;
@property (retain) NSMutableSet* delegates;

+(BrandManager*)singleton;
+(Brand*)currentBrand;

-(void)addDelegate:(id<BrandManagerDelegate>)delegate;
-(void)removeDelegate:(id<BrandManagerDelegate>)delegate;

@end


