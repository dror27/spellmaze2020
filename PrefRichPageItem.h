//
//  PrefRichPageItem.h
//  SpellMaze
//
//  Created by Dror Kessler on 12/13/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImageView.h>
#import "PrefPageItem.h"


@interface PrefRichPageItem : PrefPageItem {

	NSString*			_title;
	NSString*			_subtitle;
	
	UIImage*			_icon;
	UIImageView*		_iconView;
	
	NSURL*				_iconUrl;
	NSURLConnection*	_iconUrlConnection;
	NSMutableData*		_iconData;
	
	BOOL				narrow;
}
@property (retain) NSString* title;
@property (retain) NSString* subtitle;
@property (retain) UIImage* icon;
@property (retain) UIImageView* iconView;
@property (retain) NSURL* iconUrl;
@property (retain) NSURLConnection* iconUrlConnection;
@property (retain) NSMutableData* iconData;
@property BOOL narrow;


@end
