//
//  PrefBrowseOntologyActionImage.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/26/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefUUIDActionImage.h"
#import "SoundTheme.h"

@interface PrefBrowseOntologyActionImage : PrefUUIDActionImage {
	
	UIImageView*	_imageView;
	UILabel*		_labelView;
	UILabel*		_textView;
	UILabel*		_statusView;
	
	int				currentWordIndex;
	
	SoundTheme*		_soundTheme;
}
@property (retain) UIImageView* imageView;
@property (retain) UILabel* labelView;
@property (retain) UILabel* textView;
@property (retain) UILabel* statusView;
@property (retain) SoundTheme* soundTheme;

@end
