//
//  PrefPage.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>


@interface PrefPage : NSObject {

	NSString*	_title;
	NSArray*	_sections;
	
	UIViewController*	_pageViewController;
}
@property (retain) NSString* title;
@property (retain) NSArray* sections; 
@property (nonatomic,assign) UIViewController* pageViewController;

-(void)refresh;
-(void)appeared;
-(void)disappeared;
@end
