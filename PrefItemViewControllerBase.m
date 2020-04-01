//
//  PrefItemViewControllerBase.m
//  Board3
//
//  Created by Dror Kessler on 8/3/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefItemViewControllerBase.h"
#import "PrefItemBase.h"
#import "PrefSection.h"
#import "Constants.h"
#import "DisplayCell.h"
#import "SourceCell.h"
#import "PrefViewController.h"
#import "RTLUtils.h"

@implementation PrefItemViewControllerBase

@synthesize item = _item;
@synthesize myTableView = _myTableView;
@synthesize rowHeightIncrease = _rowHeightIncrease;
@synthesize moreSection = _moreSection;
@synthesize itemCells = _itemCells;

-(id)initWithItem:(PrefItemBase*)item
{
	if ( self = [super init] )
	{
		self.item = item;
		self.itemCells = [[[NSMutableDictionary alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[_item release];
	[_myTableView release];
	[_moreSection release];
	[_itemCells release];
	
	[super dealloc];
}

- (void)loadView 
{
	self.title = [RTLUtils rtlString:self.item.label];
	
	// create and configure the table view
	self.myTableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped] autorelease];
	_myTableView.delegate = self;
	_myTableView.dataSource = self;
	_myTableView.autoresizesSubviews = YES;
	_myTableView.scrollEnabled = NO;	// no scrolling in this case, we don't want to interfere with touch events on edit fields
	
	self.view = _myTableView;	
}

#pragma mark - UITableView delegates

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1 + (self.moreSection ? 1 : 0);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ( self.moreSection && section == 1 )
		return [RTLUtils rtlString:self.moreSection.title];
	else 
		return NULL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( self.moreSection && section == 1 )
	{
		return self.moreSection.items.count + (self.moreSection.comment != NULL);
	}
	else
		return -1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int				section = [indexPath section];
	
	if ( self.moreSection && section == 1 )
	{
		int				row = [indexPath row];

		if ( row < self.moreSection.items.count )
		{
			float		height = ((PrefItemBase*)[self.moreSection.items objectAtIndex:row]).rowHeight;
			if ( height <= 0 )
				height = kUIRowHeight;
			
			return height;
		}
		else
		{
			int		newlineCount = 0;
			for ( int n = 0 ; n < self.moreSection.comment.length ; n++ )
				if ( [self.moreSection.comment characterAtIndex:n] == '\n' )
					newlineCount++;
			return kUIRowLabelHeight * (1 + newlineCount);
		}
	}
	else
		return kUIRowHeight * (1 + self.rowHeightIncrease);
}

- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row forSection:(NSInteger)section
{
	if ( !self.moreSection || section != 1 )
		return NULL;
	
	PrefSection*	prefSection = self.moreSection;
	UITableViewCell *cell = nil;
	
	if ( row < prefSection.items.count )
		cell = [_myTableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	else
		cell = [_myTableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if ( row < prefSection.items.count )
			cell = [[[DisplayCell alloc] initWithFrame:CGRectZero reuseIdentifier:kDisplayCell_ID] autorelease];
		else
			cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
	}
	
	BOOL		nests = FALSE;
	BOOL		selectable = FALSE;
	if ( row < prefSection.items.count )
	{
		PrefItemBase*	item = [prefSection.items objectAtIndex:row];
		
		[self.itemCells setObject:cell forKey:item];
		
		nests = item.nests;
		selectable = item.selectable;
	}
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.selectionStyle = selectable ? UITableViewCellSelectionStyleBlue: UITableViewCellSelectionStyleNone;
	cell.accessoryType = nests ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	
	return cell;	
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( !self.moreSection || [indexPath section] != 1 )
		return NULL;
	
	PrefSection*	prefSection = self.moreSection;
	NSInteger		row = [indexPath row];
	
	UITableViewCell *cell = [self obtainTableCellForRow:row forSection:[indexPath section]];
	
	if ( row < prefSection.items.count )
	{
		PrefItemBase*	item = [prefSection.items objectAtIndex:row];
		
		((DisplayCell *)cell).nameLabel.text = item.label;
		((DisplayCell *)cell).view = item.control;
		item.viewController = self;
	}
	else
	{
		((SourceCell *)cell).sourceLabel.text = prefSection.comment;
	}
	
	return cell;
}

// the table's selection has changed
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( !self.moreSection || [indexPath section] != 1 )
		return;

	PrefSection*	prefSection = self.moreSection;
	NSInteger		row = [indexPath row];
	
	if ( row < prefSection.items.count )
	{
		PrefItemBase*	item = [prefSection.items objectAtIndex:row];
		
		if ( item.selectable )
			[item wasSelected:self];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [_myTableView indexPathForSelectedRow];
	if ( tableSelection )
		[_myTableView deselectRowAtIndexPath:tableSelection animated:NO];
}

@end
