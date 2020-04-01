//
//  PrefMainPageBuilder.m
//  Board3
//
//  Created by Dror Kessler on 8/1/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefMainPageBuilder.h"
#import "PrefSection.h"
#import "PrefPage.h"
#import "PrefItemBase.h"
#import "PrefBooleanItem.h"
#import "PrefFloatItem.h"
#import "PrefMultiValueItem.h"
#import "PrefStringItem.h"
#import "PrefPageItem.h"
#import "PrefImageItem.h"
#import "PrefActionItem.h"
#import "PrefDomainDownloadItem.h"
#import "PrefDomainMultiValueItem.h"
#import "LanguageManager.h"
#import "Folders.h"
#import "GameManager.h"
#import "PrefFolderPage.h"
#import "PrefDomainDirectoryListingMultiValueItem.h"
#import "PrefUrlDirectorySection.h"
#import "BrandManager.h"
#import "UIDevice_AvailableMemory.h"
#import "PrefResetToFactorySettingsActionItem.h"
#import "PrefFileActionDelegate.h"
#import "NSDictionary_TypedAccess.h"
#import "PrefViewController.h"
#import "PrefUUIDPrefsBuilder.h"
#import "PrefGameSelectionPageItem.h"
#import "RoleManager.h"
#import "SystemUtils.h"
#import "PrefIdentitiesMultiValueItem.h"
#import "PrefCreateIdentityActionItem.h"
#import "PrefDeleteIdentityActionItem.h"
#import "PrefPurchaseRecordsSection.h"
#import "StoreManager.h"
#import "Catalog.h"
#import "CatalogItem.h"
#import "PrefPromotedCatalogItemsPage.h"
#import "PrefAbraViewController.h"
#import "PrefRichPageItem.h"
#import "PrefCheckForUpdatesActionItem.h"
#import "L.h"
#import "RTLUtils.h""


@interface PrefMainPageBuilder (Privates)
-(PrefPage*)browsePage;
-(PrefSection*)moreSectionForDomain:(NSString*)domain regardingItem:(PrefItemBase*)item withPlural:(NSString*)plural;
-(PrefItemBase*)moreLanguagesItemForItem:(PrefItemBase*)item;
-(PrefItemBase*)buildPromoItemForDomain:(NSString*)domain;
@end

@implementation PrefMainPageBuilder

-(PrefPage*)buildPrefPage
{
#if TARGET_IPHONE_SIMULATOR
	{
		// save user prefs to a temp file ...
		NSUserDefaults*	ud = [NSUserDefaults standardUserDefaults];
		NSDictionary*	dict = [ud dictionaryRepresentation];
		NSData*			data = [NSPropertyListSerialization dataFromPropertyList:dict 
																	  format:NSPropertyListXMLFormat_v1_0 errorDescription:NULL];
		NSString*		outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"UserDefaults.plist"];
		[data writeToFile:outputPath atomically:FALSE];
		NSLog(@"[PrefMainPageBuilder] UserDefaults writen to: %@", outputPath);
	}
#endif
	// home section
	PrefSection*	home = [[[PrefSection alloc] init] autorelease];
	PrefImageItem*	icon;
	home.comment = @"A SpellMaze Game\nby Dror Kessler Ltd.\nCopyright © 2020";
	home.items = [NSArray arrayWithObjects:
				  icon = [[[PrefImageItem alloc] initWithLabel:@"" andKey:NULL andImage:[UIImage imageNamed:@"ProgramIcon1.png"]] autorelease],
				  NULL];
	
	// sound section
	PrefSection*	sound = [[[PrefSection alloc] init] autorelease];
	//sound.title = @"Sound";
	sound.comment = LOC(@"Setup how the game sounds");
	sound.items = [NSArray arrayWithObjects:
				   [[[PrefBooleanItem alloc] initWithLabel:LOC(@"Sound Effects") andKey:@"pref_sound_enabled" andDefaultBooleanValue:TRUE] autorelease],
				   [[[PrefBooleanItem alloc] initWithLabel:LOC(@"Speaker Voice") andKey:@"pref_tts_enabled" andDefaultBooleanValue:TRUE] autorelease],
				   NULL];
	

	// game section
	PrefSection*	game = [[[PrefSection alloc] init] autorelease];
	PrefDomainMultiValueItem*	languages;
	//game.title = @"Game";
	game.comment = LOC(@"Setup what game you're playing");
	PrefFloatItem*	speed;
	game.items = [NSArray arrayWithObjects:
				  languages = [[[PrefDomainMultiValueItem alloc] initWithLabel:LOC(@"Game") andKey:@"pref_default_language" 
																	 andDomain:DF_LANGUAGES andDefaultValue:LM_DEFAULT_LANGUAGE] autorelease],
				  speed = [[[PrefFloatItem alloc] initLogarithmicWithLabel:LOC(@"Speed") andKey:PK_GAME_SPEED 
															   andMinValue:0.25 andMaxValue:4.0 andDefaultFloatValue:1.0] autorelease],
				  nil];
	//speed.showValue = TRUE;
	languages.moreSection = [self moreSectionForDomain:DF_LANGUAGES regardingItem:languages withPlural:@"Games"];
	
		
	// score section
	PrefSection*	score = [[[PrefSection alloc] init] autorelease];
	//score.title = @"Score";
	PrefStringItem* nickname = [PrefStringItem alloc];
	nickname.stringTransformer = [RoleManager singleton];
	nickname.autocapitalizationType = UITextAutocapitalizationTypeWords;
	PrefImageItem*	nickface;
	score.comment = LOC(@"Setup your identity");
	score.items = [NSArray arrayWithObjects:
				   nickname = [[nickname initWithLabel:LOC(@"Nickname") andKey:@"pref_scoring_nickname" andDefaultStringValue:@""] autorelease],
				   nickface = [[[PrefImageItem alloc] initWithLabel:LOC(@"Nickface") andKey:@"pref_scoring_nickface" andImage:NULL] autorelease],
				   NULL];
	nickface.forcedSize = CGSizeMake(48, 48);
	[nickname refresh];
	
	// cheats
	PrefPage*		cheatsPage = NULL;
#if 0
	if ( [[RoleManager singleton] isCheater] )
	{
		PrefSection*	cheats = [[[PrefSection alloc] init] autorelease];
		NSMutableArray*	cheatsItems = [NSMutableArray arrayWithObjects:
						[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Enable All Levels") andKey:@"pref_cheat_enable_all_levels" andDefaultBooleanValue:FALSE] autorelease],
						[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Repeat Words") andKey:@"pref_cheat_repeat_words_in_level" andDefaultBooleanValue:FALSE] autorelease],
						[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Pause Levels At Will") andKey:@"pref_cheat_play_pause" andDefaultBooleanValue:FALSE] autorelease],
						[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Show Hint At Will") andKey:@"pref_cheat_show_hint" andDefaultBooleanValue:FALSE] autorelease],
						[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Disable Decorations") andKey:@"pref_cheat_disable_decorations" andDefaultBooleanValue:FALSE] autorelease],
						[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Wide Cells") andKey:@"pref_cheat_wide_cells" andDefaultBooleanValue:FALSE] autorelease],
						NULL];
		if ( [[RoleManager singleton] isDeveloper] )
		{
			[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"AR Mode") andKey:@"pref_cheat_autorun" andDefaultBooleanValue:FALSE] autorelease]];
			[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"AR Level Loop") andKey:@"pref_cheat_autorun_level_loop" andDefaultBooleanValue:FALSE] autorelease]];
			[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"AR Game Loop") andKey:@"pref_cheat_autorun_game_loop" andDefaultBooleanValue:FALSE] autorelease]];
			[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"AR Acc. Score") andKey:@"pref_cheat_autorun_accumulate_score" andDefaultBooleanValue:FALSE] autorelease]];
			[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Old Image Hint") andKey:@"pref_cheat_old_image_hint" andDefaultBooleanValue:FALSE] autorelease]];
#if !TARGET_IPHONE_SIMULATOR
			[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Apple Store") andKey:@"pref_cheat_apple_store" andDefaultBooleanValue:FALSE] autorelease]];
#endif
		}
		[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Level End Menu") andKey:@"pref_cheat_level_end_menu" andDefaultBooleanValue:FALSE] autorelease]];
		[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Text Hint M1") andKey:@"pref_cheat_text_hint" andDefaultBooleanValue:FALSE] autorelease]];
		[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Text Hint M2") andKey:@"pref_cheat_text_hint2" andDefaultBooleanValue:FALSE] autorelease]];
		[cheatsItems addObject:[[[PrefBooleanItem alloc] initWithLabel:LOC(@"Speak Spell") andKey:@"pref_cheat_speak_spell" andDefaultBooleanValue:FALSE] autorelease]];
		cheats.items = cheatsItems;
		cheatsPage = [[[PrefPage alloc] init] autorelease];
		cheatsPage.title = LOC(@"Cheats");
		cheatsPage.sections = [NSArray arrayWithObjects:cheats, nil];
	}
#endif
	
	// development
	PrefPage*		develPage = NULL;
	if ( CHEAT_ON(CHEAT_HAS_DEVELOPER_CREDENTIALS) )
	{
		PrefSection*		browse = [[[PrefSection alloc] init] autorelease];
		NSMutableArray*		browseItems = [NSMutableArray array];
		browse.comment = @"various development aids";
		
		if ( CHEAT_ON(CHEAT_FILE_SYSTEM_BROWSER) )
		{
			[browseItems addObject:[[[PrefPageItem alloc] initWithLabel:@"Browse" andKey:NULL andPage:[self browsePage]] autorelease]];
		}
		
		if ( CHEAT_ON(CHEAT_PURCHASE_RECORD_BROWSER) )
		{
			NSMutableArray*					prSections = [NSMutableArray array];
			static struct {
				int			mask;
				NSString*	name;
			} conf[] = {
				{1 << PurchaseRecordStateDownloaded,	@"Downloaded"},
				{1 << PurchaseRecordStatePurchased,		@"Purchased"},
				{1 << PurchaseRecordStateQuoted,		@"Quoted"},
				{1 << PurchaseRecordStateOutdated,		@"Outdated"},
				{1 << PurchaseRecordStateMissing,		@"Missing"},
				{0,										@"All Other"}
			};
				
			int		allOthersMask = 0xFFFF;
			for ( int confIndex = 0 ; confIndex < sizeof(conf) / sizeof(conf[0]) ; confIndex++ )
			{
				int		mask = conf[confIndex].mask;
				if ( !mask )
					mask = allOthersMask;
				else
					allOthersMask = allOthersMask & ~mask;
				
				PrefPurchaseRecordsSection*		section = [[[PrefPurchaseRecordsSection alloc] init] autorelease];
				section.stateMask = mask;
				section.title = conf[confIndex].name;
				
				[prSections addObject:section];
			}
				
			PrefPage*						purchaseRecordsPage = [[[PrefPage alloc] init] autorelease];
			purchaseRecordsPage.sections = prSections;
			purchaseRecordsPage.title = @"Purchase Records";
			
			[browseItems addObject:[[[PrefPageItem alloc] initWithLabel:[purchaseRecordsPage title] andKey:PREF_KEY_PURCHASE_RECORDS 
																andPage:purchaseRecordsPage] autorelease]];
		}
				
		if ( CHEAT_ON(CHEAT_ALLOW_GAMETYPE_SELECTION) )
		{
			PrefDomainMultiValueItem* games;
			
			games = [PrefDomainMultiValueItem alloc];
			games.prefixTitles = [NSArray arrayWithObject:@"[Default]"];
			games.prefixValues = [NSArray arrayWithObject:@""];
			games.emptyValueIsNull = TRUE;
			games = [[games initWithLabel:LOC(@"Game Type") andKey:PK_LEVEL_SET 
								andDomain:DF_GAMES andDefaultValue:NULL] autorelease];
			
			games.moreSection = [self moreSectionForDomain:DF_GAMES regardingItem:games withPlural:NULL];
			
			
			[browseItems addObject:games];
		}
		
		if ( CHEAT_ON(CHEAT_ALLOW_CATALOG_SELECTION) )
		{
			PrefDomainMultiValueItem* catalogs;
			
			catalogs = [[[PrefDomainMultiValueItem alloc] initWithLabel:LOC(@"Promo Catalog") andKey:PK_CATALOG 
															  andDomain:DF_CATALOGS andDefaultValue:DEFAULT_CATALOG] autorelease];
			
			catalogs.moreSection = [self moreSectionForDomain:DF_CATALOGS regardingItem:catalogs withPlural:NULL];
			
			
			[browseItems addObject:catalogs];
		}

		if ( CHEAT_ON(CHEAT_RESET_TO_FACTORY_SETTINGS) )
		{
			PrefResetToFactorySettingsActionItem*		reset;
		
			reset = [[[PrefResetToFactorySettingsActionItem alloc] initWithLabel:@"Reset to Factory Settings" andKey:NULL] autorelease];
			[browseItems addObject:reset];
		}
		
		browse.items = browseItems;
		
		// development	
		develPage = [[[PrefPage alloc] init] autorelease];
		develPage.title = @"Development";
		develPage.sections = [NSArray arrayWithObjects:browse, nil];	
	}
	
	PrefSection*	additionalSettings = [[[PrefSection alloc] init] autorelease];
	PrefIdentitiesMultiValueItem* identities;
	additionalSettings.comment = @"additional game settings";
	NSMutableArray*	additionalSettingsItems = [NSMutableArray array];
	additionalSettings.items = additionalSettingsItems;

	// skin
	PrefDomainMultiValueItem* skins = [[[PrefDomainMultiValueItem alloc] initWithLabel:@"Skin" andKey:PK_BRAND 
													andDomain:DF_BRANDS andDefaultValue:BM_DEFAULT_BRAND] autorelease];
	skins.moreSection = [self moreSectionForDomain:DF_BRANDS regardingItem:skins withPlural:LOC(@"Skins")];
	[additionalSettingsItems addObject:skins];
	
	// speaker voice
	[additionalSettingsItems addObject:
	 [[[PrefMultiValueItem alloc] initWithLabel:@"Speaker Voice" andKey:@"pref_voice_suffix" 
									  andTitles: [NSArray arrayWithObjects:@"Male Normal", @"Male Deep", @"Female Normal", @"Female Deep", NULL]
									  andValues: [NSArray arrayWithObjects:@"", @"+m1", @"+f4", @"+f2", NULL]
						  andDefaultStringValue:@""] autorelease]
	 ];
	
	// current player
	[additionalSettingsItems addObject:
					identities = [[[PrefIdentitiesMultiValueItem alloc] initWithLabel:@"Current Player" andKey:PK_IDENTITY_UUID andTitles:NULL andValues:NULL andDefaultStringValue:[UserPrefs userIdentity]] autorelease]
					];
	PrefSection*	createIdentSection = [[[PrefSection alloc] init] autorelease];
	createIdentSection.items = [NSArray arrayWithObjects:
								[[[PrefCreateIdentityActionItem alloc] initWithLabel:@"Create New Player!" andKey:NULL] autorelease],
								[[[PrefDeleteIdentityActionItem alloc] initWithLabel:@"Delete Selected Player!" andKey:NULL] autorelease],
								NULL];
	identities.moreSection = createIdentSection;
	
	
	// sync page
	PrefPage*						syncPage = [[[PrefPage alloc] init] autorelease];
	PrefSection*					syncPageSection = [[[PrefSection alloc] init] autorelease];
	PrefCheckForUpdatesActionItem*	syncItem = [[[PrefCheckForUpdatesActionItem alloc] initWithLabel:LOC(@"Check Now!") andKey:nil] autorelease];
	
	syncItem.itemsForUpdatePage = syncPage;
	syncPageSection.items = [NSArray arrayWithObjects:syncItem, nil];
	syncPage.sections = [NSMutableArray arrayWithObjects:syncPageSection, nil];
	syncPage.title = LOC(@"Check For Updates");

	// more
	PrefSection*	stayCurrent = [[[PrefSection alloc] init] autorelease];
	stayCurrent.items = [NSArray arrayWithObjects:
				  [[[PrefPageItem alloc] initWithLabel:syncPage.title andKey:nil andPage:syncPage] autorelease],
				  nil];
	stayCurrent.comment = LOC(@"stay current");

	
	// advanced
	PrefPage*		advancedPage = [[[PrefPage alloc] init] autorelease];
	advancedPage.title = LOC(@"Advanced Settings");
	
	advancedPage.sections = [NSArray arrayWithObjects:additionalSettings, stayCurrent, NULL];
	
	
	// others
	PrefSection*	others = [[[PrefSection alloc] init] autorelease];
	//others.title = @"More";
	NSMutableArray*	othersItems = [[[NSMutableArray alloc] init] autorelease];
	[othersItems addObject:[[[PrefPageItem alloc] initWithLabel:LOC(@"Advanced Settings") andKey:NULL andPage:advancedPage] autorelease]];
	[othersItems addObject:[self moreLanguagesItemForItem:languages]];
	if ( develPage )
		[othersItems addObject:[[[PrefPageItem alloc] initWithLabel:LOC(@"Development Aids") andKey:NULL andPage:develPage] autorelease]];
	if ( cheatsPage )
		[othersItems addObject:[[[PrefPageItem alloc] initWithLabel:LOC(@"Cheats") andKey:NULL andPage:cheatsPage] autorelease]];
	if ( CHEAT_ON(CHEAT_ALLOW_HAL_ACCESS) )
	{
		PrefPageItem*	item = [[[PrefPageItem alloc] initWithLabel:LOC(@"Talk to Alan/HAL") andKey:nil] autorelease];
		
		item.viewControllerClassName = @"PrefAbraViewController";
		
		[othersItems addObject:item];
	}
	if ( CHEAT_ON(CHEAT_ALLOW_MAGAZINE_SELECTION) )
	{
		PrefDomainMultiValueItem* magazines = [[[PrefDomainMultiValueItem alloc] initWithLabel:LOC(@"Magazine") andKey:@"pref_default_magazine" 
																						 andDomain:@"Magazines" andDefaultValue:NULL] autorelease];

		magazines.moreSection = [self moreSectionForDomain:@"Magazines" regardingItem:languages withPlural:@"Magazines"];
		
		[othersItems addObject:magazines];
		
	}
	others.items = othersItems;
	others.comment = [NSString stringWithFormat:@"Version %@, Build #%@ (%@)\n%@\nSystem Version %@\nMemory %3.1f MB",
					  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
					  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
					  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SM_BuildDate"],
					  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SM_BuildComment"],
					  [[UIDevice currentDevice] systemVersion], 
					  [UIDevice currentDevice].availableMemory];
	

	// promo
	PrefSection*	promo = NULL;
	if ( ([[BrandManager currentBrand] globalBoolean:@"catalog/props/promote-main-pref" withDefaultValue:FALSE]) )
	{
		PrefItemBase*	promoItem = [self buildPromoItemForDomain:DF_LANGUAGES];
		if ( promoItem )
		{
			promo = [[[PrefSection alloc] init] autorelease];
			promo.items = [NSArray arrayWithObject:promoItem];
		}	
	}
		
	// create preferences page
	PrefPage*		prefPage = [[[PrefPage alloc] init] autorelease];
	
	// TODO: edit to remove dups
	if ( promo )
		prefPage.sections = [NSArray arrayWithObjects:home, game, promo, score, sound, others, nil];
	else
		prefPage.sections = [NSArray arrayWithObjects:home, game, score, sound, others, nil];

	return prefPage;
}

-(PrefPage*)browsePage
{
	// setup page
	PrefPage*		page = [[[PrefPage alloc] init] autorelease];
	NSMutableArray*	sections = [[[NSMutableArray alloc] init] autorelease];
	page.sections = sections;
	
	// add sections for each role
	FolderRoleType	roles[] = {FolderRoleBuiltin, FolderRoleDownload};
	NSString*		roleNames[] = {@"Builtin", @"Download"};
	int				roleCount = sizeof(roles) / sizeof(roles[0]);
	NSString*		domains[] = {DF_LANGUAGES, DF_LEVELS, DF_GAMES, DF_BRANDS, DF_DYNAMIC};
	int				domainCount = sizeof(domains) / sizeof(domains[0]);
	for ( int roleIndex = 0 ; roleIndex < roleCount ; roleIndex++ )
	{
		NSArray*		roleOrder = [NSArray arrayWithObject:[NSNumber numberWithInt:roles[roleIndex]]];
		
		// create section
		PrefSection*	section = [[[PrefSection alloc] init] autorelease];
		NSMutableArray*	items = [[[NSMutableArray alloc] init] autorelease];
		[sections addObject:section];
		section.title = roleNames[roleIndex];
		section.items = items;
		
		// add domains
		for ( int domainIndex = 0 ; domainIndex < domainCount ; domainIndex++ )
		{
			if ( [domains[domainIndex] isEqualToString:DF_DYNAMIC] && (roles[roleIndex] != FolderRoleDownload) )
				continue;
			
			NSString*			path = [Folders roleFolder:roles[roleIndex] forDomain:domains[domainIndex]];
			PrefFolderPage*		folderPage = [[[PrefFolderPage alloc] initWithFolder:path] autorelease];
			
			NSString*			name = [NSString stringWithFormat:@"%@ (%d)", [path lastPathComponent],
										[[Folders listUUIDSubFolders:roleOrder forDomain:domains[domainIndex]] count]];
			
			
			PrefPageItem*		item = [[[PrefPageItem alloc] initWithLabel:name andKey:NULL andPage:folderPage] autorelease];
			
			[items addObject:item];
		}
		
	}
	
	
	// return page
	return page;
	
}

#define	URL_SPELLMAZE_MORE_BASE					@"http://sms.drorkessler.com/rc1/more"
#define	URL_SPELLMAZE_MORE_BASE_RC0				@"http://sms.drorkessler.com/rc0/more"

#define	URL_SIMULATOR_SPELLMAZE_MORE_BASE		@"http://localhost/rc1/more"
#define	URL_SIMULATOR_SPELLMAZE_MORE_BASE_RC0	     @"http://localhost/rc0/more"



-(PrefSection*)moreSectionForDomain:(NSString*)domain regardingItem:(PrefItemBase*)item withPlural:(NSString*)plural
{
	PrefSection*				more = [[[PrefSection alloc] init] autorelease];
	NSString*					title = [NSString stringWithFormat:@"Get More %@", plural ? plural : domain];
	NSMutableArray*				items = [[[NSMutableArray alloc] init] autorelease];
	
	more.title = LOC(title);
	
	if ( ([[BrandManager currentBrand] globalBoolean:@"catalog/props/promote-on-more" withDefaultValue:FALSE]) )
	{
		PrefItemBase*				promoItem = [self buildPromoItemForDomain:domain];
		if ( promoItem )
			[items addObject:promoItem];
	}
	
	
	NSMutableArray*				links = [[[NSMutableArray alloc] init] autorelease];
	
	// standard site link
	[links addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"SpellMaze More", @"title",
																@"Play new games, learn new languages, enjoy!", @"subtitle",
																URL_SPELLMAZE_MORE_BASE, @"url",
					  nil]];
	
	if ( CHEAT_ON(CHEAT_RC0_DIRECTORY) )
	{
		[links addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"sms.drorkessler.com (rc0)", @"title",
						  @"Release candidate 0 directory", @"subtitle",
						  URL_SPELLMAZE_MORE_BASE_RC0, @"url",
						  nil]];
	}
	
	// simulator?
#if TARGET_IPHONE_SIMULATOR
	[links addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Branded Site", @"title",
					  @"Development stuff ...", @"subtitle",
					  URL_SIMULATOR_SPELLMAZE_MORE_BASE, @"url",
					  nil]];
	if ( CHEAT_ON(CHEAT_RC0_DIRECTORY) )
	{
		[links addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Branded Site (rc0)", @"title",
						  @"Development stuff ...", @"subtitle",
						  URL_SIMULATOR_SPELLMAZE_MORE_BASE_RC0, @"url",
						  nil]];
	}
#endif
	
	// build it
	for ( NSDictionary* dict in links )
	{
		PrefPage*					morePage1 = [[[PrefPage alloc] init] autorelease];
		PrefUrlDirectorySection*	moreSection1 = [[[PrefUrlDirectorySection alloc] 
													 initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/directory.plist?ver=%@&build=%@&device=%@&identity=%@", 
																					   [dict objectForKey:@"url"], 
																					   [domain lowercaseString],
																					   [SystemUtils softwareVersion],
																					   [SystemUtils softwareBuild],
																					   [[UIDevice currentDevice] identifierForVendor],
																					   [UserPrefs userIdentity]
																					   ]]] autorelease];
		morePage1.sections = [NSArray arrayWithObject:moreSection1];
		morePage1.title = [dict objectForKey:@"title"];
		
		PrefRichPageItem*			pageItem = [[[PrefRichPageItem alloc] initWithLabel:NULL andKey:NULL andPage:morePage1] autorelease];
		pageItem.title = morePage1.title;
		pageItem.subtitle = [dict objectForKey:@"subtitle"];
		pageItem.icon = [dict objectForKey:@"icon"];
		[items addObject:pageItem];
		
		moreSection1.delegate = self;
		moreSection1.context = item;
	}
	more.items = items;
	
	return more;
}

-(PrefItemBase*)moreLanguagesItemForItem:(PrefItemBase*)item
{
	PrefPage*					morePage1 = [[[PrefPage alloc] init] autorelease];
	PrefUrlDirectorySection*	moreSection1 = [[[PrefUrlDirectorySection alloc] 
												 initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/directory.plist?ver=%@&build=%@&device=%@&identity=%@", 
																				   URL_SPELLMAZE_MORE_BASE, 
																				   [DF_LANGUAGES lowercaseString],
																				   [SystemUtils softwareVersion],
																				   [SystemUtils softwareBuild],
																				   [[UIDevice currentDevice] identifierForVendor],
																				   [UserPrefs userIdentity]
																				   ]]] autorelease];
	morePage1.sections = [NSArray arrayWithObject:moreSection1];
	morePage1.title = LOC(@"Get More Games");
	
	PrefItemBase*		item1 = [[[PrefPageItem alloc] initWithLabel:morePage1.title andKey:NULL andPage:morePage1] autorelease];
	
	moreSection1.delegate = self;
	moreSection1.context = item;
	
	return item1;
}



-(void)urlDirectoryDidDownload:(NSString*)uuid withContext:(id)context
{
	PrefItemBase*	item = context;
	
	if ( uuid && item )
	{		
		if ( item.key )
			[UserPrefs setString:item.key withValue:uuid force:TRUE];
		
		BOOL		autoPush = FALSE;
		PrefPage*	prefPage = nil;
		if ( [item isKindOfClass:[PrefDomainMultiValueItem class]] )
		{
			PrefDomainMultiValueItem*	domainItem = (PrefDomainMultiValueItem*)item;
			
			prefPage = [domainItem detailForValue:uuid];
			
			if ( [PrefMainPageBuilder findStartupItemInPage:prefPage] )
				autoPush = TRUE;
		}
		
		if ( item.viewController && !autoPush )
		{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController*        viewController = item.viewController;
                
                if ( !viewController.navigationController &&
                        [viewController respondsToSelector:@selector(flippedFrom)] )
                    viewController = [viewController performSelector:@selector(flippedFrom)];

                if ( viewController.navigationController )
                    [self performSelectorOnMainThread:@selector(popAnimated:) withObject:viewController waitUntilDone:FALSE];
            });
		}
		
		[item refresh];
		
		if ( autoPush )
		{
			if ( prefPage )
				[self performSelectorOnMainThread:@selector(pushIntoDetailInstance:) withObject:[NSArray arrayWithObjects:item, prefPage, nil] waitUntilDone:FALSE];
		}
	}
}

-(void)popAnimated:(UIViewController*)viewController
{
	[viewController.navigationController popToViewController:viewController animated:TRUE];
}

-(void)pushIntoDetailInstance:(NSArray*)args
{
	[PrefMainPageBuilder pushIntoDetail:args];
}

+(void)pushIntoDetail:(NSArray*)args
{
	PrefDomainMultiValueItem*	item = [args objectAtIndex:0];
	PrefPage*					page = [args objectAtIndex:1];	
	UIViewController*			viewController = item.viewController;
	
	if ( !viewController.navigationController &&
		[viewController respondsToSelector:@selector(flippedFrom)] )
		viewController = [viewController performSelector:@selector(flippedFrom)];
	
	if ( viewController.navigationController )
	{
		UIViewController*	next = [[[PrefViewController alloc] initWithPrefPage:page] autorelease];
		
		[viewController.navigationController popToViewController:viewController animated:FALSE];
		[viewController.navigationController pushViewController:next animated:TRUE];
		
		PrefItemBase*	startupItem = [PrefMainPageBuilder findStartupItemInPage:page];
		if ( startupItem )
			[startupItem performSelectorOnMainThread:@selector(wasSelected:) withObject:next waitUntilDone:FALSE];
	}
}	

-(PrefItemBase*)buildPromoItemForDomain:(NSString*)domain
{	
	// recommendatiaons ...
	NSArray*					recItems = [[Catalog currentCatalog] itemsForDomain:domain];
	if ( [recItems count] )
	{
		CatalogItem*					firstItem = [recItems objectAtIndex:0];
		UIImage*						bannerImage = [firstItem bannerImage];
		PrefPromotedCatalogItemsPage*	promos = [[[PrefPromotedCatalogItemsPage alloc] initWithCatalogItems:recItems] autorelease];
		
		promos.title = LOC(@"Especially For You!");
		
		if ( bannerImage )
		{
			PrefImageItem*	item = [[[PrefImageItem alloc] initWithLabel:nil andKey:nil andImage:bannerImage] autorelease];
			
			item.nextPage = promos;
			
			return item;
		}
		else
		{
			PrefPageItem*	item = [[[PrefPageItem alloc] initWithLabel:promos.title andKey:nil andPage:promos] autorelease];
			
			return item;
		}
	}
	else
		return NULL;
}


+(PrefItemBase*)findStartupItemInPage:(PrefPage*)page
{
	for ( PrefSection* section in page.sections )
		for ( PrefItemBase* item in section.items )
			if ( item.startup )
				return item;
	
	return nil;
}
@end
