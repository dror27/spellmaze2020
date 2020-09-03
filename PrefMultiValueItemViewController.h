//
//  PrefMultiValueItemViewController.h
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefMultiValueItem.h"
#import "PrefItemViewControllerBase.h"
#import "LabelCell.h"

@interface PrefMultiValueItemViewController : PrefItemViewControllerBase<UITableViewDataSource,UITableViewDelegate,LabelCellDelegate> {

}
@property (readonly) PrefMultiValueItem* typedItem;
@end
