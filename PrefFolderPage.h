//
//  PrefFolderPage.h
//  Board3
//
//  Created by Dror Kessler on 8/10/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefPage.h"

@interface PrefFolderPage : PrefPage {

	NSString*		_path;
}
@property (retain) NSString* path;

-(id)initWithFolder:(NSString*)path;

@end
