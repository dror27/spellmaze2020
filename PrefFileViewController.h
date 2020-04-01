//
//  PrefFileViewController.h
//  Board3
//
//  Created by Dror Kessler on 8/11/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PrefFileViewController : UIViewController {

	NSString*		_path;
}
@property (retain) NSString* path;

-(id)initWithArgument:(NSObject*)path;
@end
