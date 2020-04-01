//
//  PrefImageItem.h
//  Board3
//
//  Created by Dror Kessler on 8/4/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PrefItemBase.h"
#import "PrefPage.h"

@interface PrefImageItem : PrefItemBase<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

	UIImage*	_image;
	NSURL*		_imageUrl;
	UIImage*	_defaultImage;
	
	CGSize		_forcedSize;
	
	PrefPage*	_nextPage;
	
}
@property (retain) UIImage* image;
@property (retain) NSURL* imageUrl;
@property (retain) UIImage* defaultImage;
@property CGSize forcedSize;
@property (retain) PrefPage* nextPage;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andImage:(UIImage*)image;
-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andImageURL:(NSURL*)imageUrl;


@end
