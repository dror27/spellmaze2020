//
//  PrefItemViewControllerBase.h
//  Board3
//
//  Created by Dror Kessler on 8/3/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrefItemBase;
@class PrefSection;

@interface PrefItemViewControllerBase : UIViewController<UITableViewDataSource,UITableViewDelegate> {

	PrefItemBase*			_item;
	UITableView*			_myTableView;
	float					_rowHeightIncrease;
	
	PrefSection*			_moreSection;
	
	NSMutableDictionary*	_itemCells;
}
@property (retain) PrefItemBase* item;
@property (retain) UITableView* myTableView;
@property float rowHeightIncrease;
@property (retain) PrefSection* moreSection;
@property (retain) NSMutableDictionary* itemCells;


-(id)initWithItem:(PrefItemBase*)item;
-(UITableViewCell *)obtainTableCellForRow:(NSInteger)row forSection:(NSInteger)section;

@end
