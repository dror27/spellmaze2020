//
//  PrefShowOntologyImagesActionItem.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/18/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefUUIDActionImage.h"
#import "Language.h"


@interface PrefShowOntologyImagesActionImage : PrefUUIDActionImage {

	UIImageView*	_imageView;
	UILabel*		_labelView;
	int				wordIndex;
	id<Language>	_language;
	
}
@property (retain) UIImageView* imageView;
@property (retain) UILabel* labelView;
@property (retain) id<Language> language;



@end
