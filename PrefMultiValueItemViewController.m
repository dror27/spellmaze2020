//
//  PrefMultiValueItemViewController.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefMultiValueItemViewController.h"
#import "Constants.h"
#import "LabelCell.h"
#import "DisplayCell.h"
#import "UserPrefs.h"
#import "PrefPage.h"
#import "PrefMultiValueItem.h"
#import "PrefViewController.h"
#import "PrefRichPageItem.h"
#import "NSDictionary_TypedAccess.h"
#import "L.h"
#import "RTLUtils.h"

@implementation PrefMultiValueItemViewController

-(PrefMultiValueItem*)typedItem
{
	return (PrefMultiValueItem*)_item;
}

- (void)loadView 
{
	[super loadView];
	
	_myTableView.scrollEnabled = YES;
}


#pragma mark - UITableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int		rows = [super tableView:tableView numberOfRowsInSection:section];
	
	if ( rows < 0 )
		rows = self.typedItem.values.count;
	
	return rows;
}

- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row forSection:(NSInteger)section
{
	UITableViewCell*	cell = [super obtainTableCellForRow:row forSection:section];
	if ( cell )
		return cell;
	
	cell = [_myTableView dequeueReusableCellWithIdentifier:kLabelCell_ID];
		
	if (cell == nil)
		cell = [[[LabelCell alloc] initWithFrame:CGRectZero reuseIdentifier:kLabelCell_ID] autorelease];
	
	BOOL	checked = FALSE;
	if ( [self.typedItem.value isEqualToString:[self.typedItem.values objectAtIndex:row]] )
		checked = TRUE;
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell*	cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if ( cell )
		return cell;
	
	NSInteger		row = [indexPath row];
	
	cell = [self obtainTableCellForRow:row forSection:[indexPath section]];
	NSString*		value = [self.typedItem.values objectAtIndex:row];
	BOOL			hasDetails = [self.typedItem detailExistsForValue:value];

	NSMutableDictionary*	props = [self.typedItem.props objectAtIndex:row];
	if ( !props )
	{
		((LabelCell *)cell).label.text = [RTLUtils rtlString:[self.typedItem.titles objectAtIndex:row]];
	}
	else
	{
		((LabelCell *)cell).label.text = @"";
		
		PrefRichPageItem*	item = [[[PrefRichPageItem alloc] init] autorelease];
		item.title = [props stringForKey:@"title" withDefaultValue:@""];
		item.subtitle = [props stringForKey:@"subtitle" withDefaultValue:@""];
		item.icon = [props objectForKey:@"icon" withDefaultValue:nil];
		item.narrow = hasDetails;
		
		((LabelCell*)cell).control = [item control];
	}
		
	
	[((LabelCell *)cell) setDetails:hasDetails];
	[((LabelCell *)cell) setDelegate:hasDetails ? self : NULL];
	[((LabelCell *)cell) setContext:hasDetails ? value : NULL];
	
	return cell;
}

// the table's selection has changed
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// NOTE: dependency on section being handled here always first
	if ( [indexPath section] )
	{
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
	else
	{
		NSInteger		row = [indexPath row];
		self.typedItem.value = [self.typedItem.values objectAtIndex:row];
	
		[self.navigationController popViewControllerAnimated:TRUE];
	}
}

-(void)detailsSelected:(id<NSObject>)context
{
	NSString*		value = (NSString*)context;
	
	PrefPage*		page = [self.typedItem detailForValue:value];
	if ( page )
	{
		PrefViewController					*next = [[PrefViewController alloc] initWithPrefPage:page];
		
		[self.navigationController pushViewController:next animated:TRUE];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int				section = [indexPath section];
	
	// only handling first/main section
	if ( section == 0 )
	{
		// has props?
		NSMutableDictionary*	props = [self.typedItem.props objectAtIndex:[indexPath row]];
		if ( props )
		{
			return [[[[PrefRichPageItem alloc] init] autorelease] rowHeight];
		}
	}
	
	// if here, goto default
	return [super tableView:tableView heightForRowAtIndexPath:indexPath];

}




@end
