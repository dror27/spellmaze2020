//
//  PrefImageSequenceItem.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/7/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefItemBase.h"
#import	"ImageSequenceMediaView.h"

@interface PrefImageSequenceItem : PrefItemBase {

	NSString*		_folder;
	NSDictionary*	_props;
	
	ImageSequenceMediaView*	_mediaView;
	float			width;
	float			height;
	float			textWidth;
	NSString*		_text;
}
@property (retain) NSString* folder;
@property (retain) NSDictionary* props;
@property (retain) ImageSequenceMediaView* mediaView;
@property (retain) NSString* text;

-(id)initWithLabel:(NSString*)label andKey:(NSString*)key andFolder:(NSString*)folder andProps:(NSDictionary*)props;

@end
