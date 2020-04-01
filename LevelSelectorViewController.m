//
//  LevelSelectorViewController.m
//  Board3
//
//  Created by Dror Kessler on 6/29/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "LevelSelectorViewController.h"
#import "GameLevel.h"
#import "ItemSelectorWidget.h"
#import "GameLevelSequence.h"
#import "GameManager.h"
#import "GameLevelSequenceViewController.h"
#import "UserPrefs.h"
#import "BrandManager.h"
#import "ScoresDatabase.h"
#import "NSDictionary_TypedAccess.h"
#import "GlobalDefs.h"
#import "L.h"
@implementation LevelSelectorViewController
@synthesize itemSelector = _itemSelector;

-(id)init
{
	if ( self = [super init] )
	{
		GameLevelSequence*	seq = [GameManager currentGameLevelSequence];
		
		// build item selector
		self.itemSelector = [[[ItemSelectorWidget alloc] init] autorelease];
		
		_itemSelector.boardFormula = [seq.upl getString:@"board-formula" withDefault:nil];
		
		NSArray*			cellLabels = [seq.upl getObject:@"cell-labels" withDefault:nil];
		
		int					levelCount = [seq levelCount];
		for ( int levelIndex = 0 ; levelIndex < levelCount ; levelIndex++ )
		{
			GameLevel*		level = [seq levelAtIndex:levelIndex];
			
			int				index = [self.itemSelector addItem:[level title] andShortDescription:[level shortDescription]];
			
			if ( cellLabels && levelIndex < [cellLabels count] )
				[_itemSelector setItemLabel:[cellLabels objectAtIndex:levelIndex] atIndex:index];
			
			[self.itemSelector setItemAction:@selector(doLevelSelected:bySender:) withTarget:self atIndex:index];
		}
		[self.itemSelector setSpeakSelection:TRUE];
		
		// add cell headings
		for ( NSDictionary* dict in [seq.upl getObject:@"cell-headings" withDefault:nil] )
		{
			int			index = [dict integerForKey:@"index" withDefaultValue:-1];
			if ( index < 0 )
				continue;
			index = [_itemSelector addItem:[dict objectForKey:@"name"] andShortDescription:[dict objectForKey:@"description"]];
			[_itemSelector setItemLabel:[dict objectForKey:@"label"] atIndex:index];
			[self.itemSelector setItemAction:@selector(doHeadingSelected:bySender:) withTarget:self atIndex:index];
			[self.itemSelector setItemEnabled:TRUE atIndex:index];
		}
	}
	return self;
}

-(void)dealloc
{
	for ( int levelIndex = 0 ; levelIndex < [_itemSelector itemCount] ; levelIndex++ )
		[self.itemSelector setItemAction:nil withTarget:nil atIndex:levelIndex];
		
	[_itemSelector release];
	
	[super dealloc];
}

-(void)loadView
{
	// Create a custom view hierarchy.
	CGRect		frame =	[UIScreen mainScreen].bounds;
	frame.origin.y = FRAME_ORIGIN_Y_OFS;
	UIView		*view = [[UIView alloc] initWithFrame:frame];
	self.view = view;
	view.backgroundColor = [[BrandManager currentBrand] globalBackgroundColor];
	
	UIImageView*	backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background-levels" withDefaultValue:NULL];
	if ( !backgroundImageView )
		backgroundImageView = [[BrandManager currentBrand] globalImageView:@"background" withDefaultValue:NULL];
	if ( backgroundImageView )
		[self.view addSubview:backgroundImageView];
	
	self.title = LOC(@"Select Level");
	
	[self.view addSubview:[self.itemSelector viewWithFrame:[self.view frame]]];
	[self.itemSelector paintItems];
	
	GameLevelSequence*	seq = [GameManager currentGameLevelSequence];
	if ( seq.helpSplashPanel )
	{
		UIBarButtonItem* item = [[[UIBarButtonItem alloc] initWithTitle:LOC(@"Help") 
														style:UIBarButtonItemStyleBordered target:self action:@selector(helpAction:)] autorelease];
		self.navigationItem.rightBarButtonItem = item;
	}
	
}

-(void)helpAction:(id)sender
{
	GameLevelSequence*	seq = [GameManager currentGameLevelSequence];
	if ( seq.helpSplashPanel )
		[seq.helpSplashPanel toggle];
}

-(void)viewWillAppear:(BOOL)animated
{
	GameLevelSequence*	seq = [GameManager currentGameLevelSequence];
	BOOL				hideDisabledLevels = [seq.props booleanForKey:@"hide-disabled-levels" withDefaultValue:FALSE];
	self.itemSelector.hideDisabledItems = hideDisabledLevels;

	int					levelCount = [seq levelCount];
	ScoresDatabase*		sdb = [ScoresDatabase singleton];
	int					globalScore = [sdb globalScore];
	NSString*			langUUID = [[seq language] uuid];
	for ( int levelIndex = 0 ; levelIndex < levelCount ; levelIndex++ )
	{
		GameLevel*		level = [seq levelAtIndex:levelIndex];
		int				scoreDisplayOffset = -globalScore + [sdb maxScoreForLevel:[level uuid] onLanguage:langUUID];
		
		[self.itemSelector setItemEnabled:[UserPrefs levelEnabled:[level uuid]] atIndex:levelIndex];
		[self.itemSelector setItemChecked:[UserPrefs levelPassed:level] atIndex:levelIndex];
		[self.itemSelector setItemChecked2:[UserPrefs levelExhausted:level] atIndex:levelIndex];
		[[self.itemSelector itemPropsAtIndex:levelIndex] setObject:[NSNumber numberWithInt:scoreDisplayOffset] forKey:@"ScoreDisplayOffset"];
	}	

	[self.itemSelector appeared];
	[self.itemSelector setMessage:seq.title andSubMessage:seq.shortDescription];
	
	[_itemSelector.panel setScoreDisplayOffset:-globalScore + [sdb bestScoreForGame:[seq uuid] onLanguage:langUUID]];	
}

-(void)viewWillDisappear:(BOOL)animated
{
	GameLevelSequence*	seq = [GameManager currentGameLevelSequence];
	if ( seq.helpSplashPanel )
		[seq.helpSplashPanel abort];
}

-(void)viewDidDisappear:(BOOL)animated
{
	[self.itemSelector disappeared];
}

-(void)doLevelSelected:(int)levelIndex bySender:(id<HasView>)sender
{
	[self.itemSelector reset];
	GameLevelSequenceViewController*		next = [[[GameLevelSequenceViewController alloc] init] autorelease];
	next.levelIndex = levelIndex;
	
	[self.navigationController pushViewController:next animated:TRUE];
}	

-(void)doHeadingSelected:(int)levelIndex bySender:(id<HasView>)sender
{
}	



@end
