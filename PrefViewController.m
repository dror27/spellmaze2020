//
//  PrefViewController.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefViewController.h"
#import "Constants.h"
#import "DisplayCell.h"
#import "SourceCell.h"
#import "PrefPage.h"
#import "PrefSection.h"
#import "PrefBooleanItem.h"
#import "PrefMultiValueItem.h"
#import	"PrefFloatItem.h"
#import "SystemUtils.h"
#import "GameManager.h"
#import "GameLevelSequence.h"
#import "SplashPanel.h"
#import "NSDictionary_TypedAccess.h"
#import "PrefMainPageBuilder.h"
#import "GlobalDefs.h"
#import "L.h"
#import "RTLUtils.h"


@implementation PrefViewController
@synthesize myTableView = _myTableView;
@synthesize flippedFrom = _flippedFrom;
@synthesize prefPage = _prefPage;
@synthesize itemCells = _itemCells;

-(id)init
{
	if ( self = [super init] )
	{
		self.itemCells = [[[NSMutableDictionary alloc] init] autorelease];
	}
	return self;	
}

-(id)initWithPrefPage:(PrefPage*)initPrefPage topPage:(BOOL)topPage
{
	if ( self = [self init] )
	{
		self.prefPage = initPrefPage;
		
		if ( topPage )
		{
			[UserPrefs addKeyDelegate:self forKey:PK_LANG_DEFAULT];
		}
	}
	return self;
}

-(id)initWithPrefPage:(PrefPage*)initPrefPage
{
	if ( self = [self initWithPrefPage:initPrefPage topPage:FALSE] )
	{
		self.prefPage = initPrefPage;
	}
	return self;
}

-(id)retain
{
	return [super retain];
}

-(void)dealloc
{
	[_myTableView release];
	[_prefPage release];
	[_itemCells release];

	[UserPrefs removeKeyDelegate:self forKey:PK_LANG_DEFAULT];
	
	[super dealloc];
}

- (void)loadView 
{
	self.title = self.prefPage.title ? RTL(self.prefPage.title) : LOC(@"Preferences");

	// create and configure the table view
	CGRect		frame = [[UIScreen mainScreen] bounds];
	frame.origin.y = FRAME_ORIGIN_Y_OFS;
	self.myTableView = [[[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped] autorelease];
	_myTableView.delegate = self;
	_myTableView.dataSource = self;
	_myTableView.autoresizesSubviews = YES;
	self.view = _myTableView;
}

-(void)disableScroll
{
	_myTableView.scrollEnabled = FALSE;
}

- (void)viewWillAppear:(BOOL)animated
{
	_prefPage.pageViewController = self;
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [_myTableView indexPathForSelectedRow];
	if ( tableSelection )
		[_myTableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[_prefPage appeared];	
}



-(void)refresh
{
	[_prefPage refresh];
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return _prefPage.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[_prefPage.sections objectAtIndex:section] title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	PrefSection*	prefSection = [_prefPage.sections objectAtIndex:section];
	
 	return prefSection.items.count + (prefSection.comment != NULL);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PrefSection*	prefSection = [_prefPage.sections objectAtIndex:[indexPath section]];
	int				row = [indexPath row];
	
	if ( row < prefSection.items.count )
	{
		PrefItemBase*	item = [prefSection.items objectAtIndex:row];
		float			height = kUIRowLabelHeight;
		
		if ( !item.sourceLabel )
		{
			height = ((PrefItemBase*)[prefSection.items objectAtIndex:row]).rowHeight;
			if ( height <= 0 )
				height = kUIRowHeight;
		}
		else
		{
			int		newlineCount = 0;
			for ( int n = 0 ; n < item.label.length ; n++ )
				if ( [item.label characterAtIndex:n] == '\n' )
					newlineCount++;

			height = kUIRowLabelHeight * (1 + newlineCount);
		}

		return height;
	}
	else
	{
		int		newlineCount = 0;
		for ( int n = 0 ; n < prefSection.comment.length ; n++ )
			if ( [prefSection.comment characterAtIndex:n] == '\n' )
				newlineCount++;
		return kUIRowLabelHeight * (1 + newlineCount);
	}
}

- (UITableViewCell *)obtainTableCellForRow:(NSInteger)row forSection:(NSInteger)section
{
	PrefSection*	prefSection = [_prefPage.sections objectAtIndex:section];
	UITableViewCell *cell = nil;
	PrefItemBase*	item = (row < prefSection.items.count) ? [prefSection.items objectAtIndex:row] : nil;
	
	if ( row < prefSection.items.count )
	{
		if ( !item.sourceLabel )
			cell = [_myTableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
		else
			cell = [_myTableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	}
	else
		cell = [_myTableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	
	if (cell == nil)
	{
		if ( row < prefSection.items.count )
		{
			if ( !item.sourceLabel )
				cell = [[[DisplayCell alloc] initWithFrame:CGRectZero reuseIdentifier:kDisplayCell_ID] autorelease];
			else
				cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
		}
		else
			cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:kSourceCell_ID] autorelease];
	}
	
	BOOL		nests = FALSE;
	BOOL		selectable = FALSE;
	if ( row < prefSection.items.count )
	{
		[_itemCells setObject:cell forKey:item];
		
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
	PrefSection*	prefSection = [_prefPage.sections objectAtIndex:[indexPath section]];
	NSInteger		row = [indexPath row];
	
	UITableViewCell *cell = [self obtainTableCellForRow:row forSection:[indexPath section]];
	
	if ( row < prefSection.items.count )
	{
		PrefItemBase*	item = [prefSection.items objectAtIndex:row];
		
		if ( !item.sourceLabel )
		{
			((DisplayCell *)cell).nameLabel.text = [RTLUtils rtlString:item.label];
			((DisplayCell *)cell).view = item.control;
			item.labelLabel = ((DisplayCell *)cell).nameLabel;
		}
		else
		{
			((SourceCell *)cell).sourceLabel.text = [RTLUtils rtlString:item.label];
			item.labelLabel = ((SourceCell *)cell).sourceLabel;			
		}
		item.viewController = self;
	}
	else
	{
		((SourceCell *)cell).sourceLabel.text = prefSection.comment;
		prefSection.commentLabel = ((SourceCell *)cell).sourceLabel;
	}
	
	return cell;
}

// the table's selection has changed
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PrefSection*	prefSection = [_prefPage.sections objectAtIndex:[indexPath section]];
	NSInteger		row = [indexPath row];

	if ( row < prefSection.items.count )
	{
		PrefItemBase*	item = [prefSection.items objectAtIndex:row];
		
		if ( item.selectable )
			[item wasSelected:_flippedFrom ? _flippedFrom : self];
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	_prefPage.pageViewController = nil;
	[_prefPage disappeared];
	
	// disconnect all items from their controls
	for ( PrefSection* section in _prefPage.sections )
	{
		section.commentLabel = nil;
		
		for ( PrefItemBase* item in section.items )
		{
			item.labelLabel = nil;
			//item.viewController = nil;
		}
	}
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	//[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkGame) object:self];
	[self performSelector:@selector(checkGame) withObject:self afterDelay:0.2];
}

-(void)checkGame
{
	GameLevelSequence*		seq = [GameManager currentGameLevelSequence];
	
	[GameManager gameReady:seq withSplashDelegate:self];
}

-(void)splashDidShow:(SplashPanel*)panel
{
}

-(void)splashDidFinish:(SplashPanel*)panel
{
	NSString*	role = [panel.props stringForKey:@"role" withDefaultValue:nil];
	
	panel.delegate = nil;
	
	if ( [role isEqualToString:@"update"] )
	{
		[panel autorelease];
		
		[self drillIntoItemByKey:PK_LANG_DEFAULT];
	}
}

-(void)drillIntoItemByKey:(NSString*)key
{
	for ( PrefSection* section in [_prefPage sections] )
		for ( PrefItemBase* item in [section items] )
			if ( [item.key isEqualToString:PK_LANG_DEFAULT] && [item isKindOfClass:[PrefMultiValueItem class]] )
			{
				[item wasSelected:(_flippedFrom ? _flippedFrom : self)];
				[self performSelector:@selector(drillIntoItemDetail:) withObject:item afterDelay:1.2];
				break;
			}	
}

-(void)drillIntoItemDetail:(PrefMultiValueItem*)item
{
	NSString*		value = item.value;
	if ( [item detailExistsForValue:value] )
	{
		PrefPage*	page = [item detailForValue:value];
		
		if ( page )
		{
			PrefViewController					*next = [[PrefViewController alloc] initWithPrefPage:page];
			UINavigationController*				navigationController = (self.navigationController ? self.navigationController : _flippedFrom.navigationController);
			
			[navigationController pushViewController:next animated:TRUE];
			
			PrefItemBase*	startupItem = [PrefMainPageBuilder findStartupItemInPage:page];
			if ( startupItem )
				[startupItem performSelectorOnMainThread:@selector(wasSelected:) withObject:next waitUntilDone:FALSE];
			
		}
	}
}

-(void)refreshTableContents:(id)sender
{
	[_myTableView reloadData];
}

// HACK
-(void)autoGameSelection:(id)sender
{
	// always on the first item of the second section
	PrefItemBase*		item = [[[[_prefPage sections] objectAtIndex:1] items] objectAtIndex:0];
	
	[item wasSelected:_flippedFrom];
}	

@end
