//
//  PrefViewController.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserPrefs.h"
#import "SplashPanel.h"


@class PrefPage;
@interface PrefViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UserPrefsDelegate,SplashPanelDelegate> {

	UITableView*		_myTableView;
	
	PrefPage*			_prefPage;

	UIViewController*	_flippedFrom;
	
	NSMutableDictionary* _itemCells;
}
@property (nonatomic,retain) UITableView *myTableView;
@property (nonatomic,assign) UIViewController* flippedFrom;
@property (retain) PrefPage* prefPage;
@property (retain) NSMutableDictionary* itemCells;

-(id)initWithPrefPage:(PrefPage*)initPrefPage;
-(id)initWithPrefPage:(PrefPage*)initPrefPage topPage:(BOOL)topPage;

-(void)drillIntoItemByKey:(NSString*)key;

-(void)refreshTableContents:(id)sender;

@end
