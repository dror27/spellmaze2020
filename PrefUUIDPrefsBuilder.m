//
//  PrefUUIDPrefsBuilder.m
//  Board3
//
//  Created by Dror Kessler on 8/19/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PrefUUIDPrefsBuilder.h"
#import "NSDictionary_TypedAccess.h"
#import "PrefPage.h"
#import "PrefSection.h"
#import "PrefItemBase.h"
#import "PrefBooleanItem.h"
#import "PrefFloatItem.h"
#import "PrefStringItem.h"
#import "PrefPageItem.h"
#import "PrefLabelItem.h"
#import "GameLevelSequence.h"
#import "GameLevel.h"
#import "Folders.h"
#import "PrefActionItem.h"
#import	"PrefThreadedActionItem.h"
#import "PrefUUIDActionItem.h"
#import "PrefDomainMultiValueItem.h"
#import "PrefMultiValueItem.h"
#import "PrefUUIDActionLabel.h"
#import "PrefUUIDActionImage.h"

@implementation PrefUUIDPrefsBuilder

-(PrefPage*)pageForGameLevelSequence:(GameLevelSequence*)seq
{
	PrefPage*			page = [[[PrefPage alloc] init] autorelease];
	
	// sub-levels section
	PrefSection*		section = [[[PrefSection alloc] init] autorelease];
	NSMutableArray*		items = [[[NSMutableArray alloc] init] autorelease];
	for ( int levelIndex = 0 ; levelIndex < [seq levelCount] ; levelIndex++ )
	{
		GameLevel*			level = [seq levelAtIndex:levelIndex];
		if ( !level )
			continue;
		NSString*			path = [Folders findUUIDSubFolder:NULL forDomain:DF_LEVELS withUUID:[level uuid]];
		if ( !path )
			continue;
		NSDictionary*		props = [Folders getMutableFolderProps:path];
		if ( !props )
			continue;
		NSArray*			prefs = [props objectForKey:@"prefs"];
		
		if ( prefs )
		{
			PrefPage*		page = [self pageForUUID:[level uuid] forDomain:DF_LEVELS fromArray:prefs];
			page.title = [level title];
			
			PrefPageItem*	item = [[[PrefPageItem alloc] initWithLabel:[level title] andKey:NULL 
											andPage:page] autorelease];
			
			[items addObject:item];
		}
	}
	section.items = items;
	
	// game section
	PrefPage*			gamePage = NULL;
	NSString*			path = [Folders findUUIDSubFolder:NULL forDomain:DF_GAMES withUUID:[seq uuid]];
	if ( path )
	{
		NSDictionary*		props = [Folders getMutableFolderProps:path];
		if ( props )
		{
			NSArray*			prefs = [props objectForKey:@"prefs"];
	
			if ( prefs )
				gamePage = [self pageForUUID:[seq uuid] forDomain:DF_GAMES fromArray:prefs];
		}
	}
	
	// connect it all
	NSMutableArray*		sections = [[[NSMutableArray alloc] init] autorelease];
	[sections addObject:section];
	if ( gamePage )
		[sections addObjectsFromArray:[gamePage sections]];
	page.sections = sections;
	
	return page;
}

-(PrefPage*)pageForUUID:(NSString*)uuid forDomain:(NSString*)domain fromArray:(NSArray*)array
{
	PrefPage*			page = [[[PrefPage alloc] init] autorelease];
	NSMutableArray*		sections = [[[NSMutableArray alloc] init] autorelease];
	
	for ( NSDictionary* dict in array )
		[sections addObject:[self sectionForUUID:uuid forDomain:domain fromDictionary:dict]];
	page.sections = sections;
	
	return page;
}

-(PrefSection*)sectionForUUID:(NSString*)uuid forDomain:(NSString*)domain fromDictionary:(NSDictionary*)dict
{
	PrefSection*		section = [[[PrefSection alloc] init] autorelease];
	NSMutableArray*		items = [[[NSMutableArray alloc] init] autorelease];
	
	section.title = [dict objectForKey:@"title"];
	section.comment = [dict objectForKey:@"comment"];
	for ( NSDictionary* itemDict in [dict arrayForKey:@"items" withDefaultValue:[NSArray array]] )
		[items addObject:[self itemForUUID:uuid forDomain:domain fromDictionary:itemDict]];
	section.items = items;
	
	return section;
}

-(PrefItemBase*)itemForUUID:(NSString*)uuid forDomain:(NSString*)domain fromDictionary:(NSDictionary*)dict
{
	NSString*		type = [dict objectForKey:@"type"];
	NSString*		label = [dict objectForKey:@"label"];
	NSString*		key = [dict objectForKey:@"key"];
	NSString*		relatedKey = [dict objectForKey:@"related-key"];
	
	if ( [type isEqualToString:@"Page"] )	
	{
		PrefPage*				page = [self pageForUUID:uuid forDomain:domain fromArray:[dict arrayForKey:@"value" withDefaultValue:[NSArray array]]];
		page.title = label;
		PrefPageItem*			item = [[[PrefPageItem alloc] initWithLabel:label andKey:key andPage:page] autorelease];
		
		item.relatedKey = relatedKey;
		return item;
	}
#if SCRIPTING
	else if ( [type isEqualToString:@"Action"] )	
	{
		PrefUUIDActionItem*		item = [[[PrefUUIDActionItem alloc] initWithLabel:label andKey:key] autorelease];
		
		item.uuid = uuid;
		item.domain = domain;
		item.actionScript = [dict stringForKey:@"value" withDefaultValue:@"ActionNameMissing"];
		item.param = [dict stringForKey:@"param" withDefaultValue:@""];
		
		item.relatedKey = relatedKey;
		return item;
	}
#endif
	else if ( [type isEqualToString:@"ActionItem"] )	
	{
		NSString*				value = [dict stringForKey:@"value" withDefaultValue:@"ActionItemNameMissing"];
		Class					itemClass = [[NSBundle mainBundle] classNamed:value];
		PrefUUIDActionItem*		item = [[[itemClass alloc] initWithLabel:label andKey:key] autorelease];
		
		item.uuid = uuid;
		item.domain = domain;
		item.param = [dict stringForKey:@"param" withDefaultValue:@""];
		item.startup = [dict booleanForKey:@"startup" withDefaultValue:FALSE];
		
		item.relatedKey = relatedKey;
		return item;
	}
	else if ( [type isEqualToString:@"ActionLabel"] )	
	{
		NSString*				value = [dict stringForKey:@"value" withDefaultValue:@"ActionLabelNameMissing"];
		Class					itemClass = [[NSBundle mainBundle] classNamed:value];
		PrefUUIDActionLabel*	item = [[[itemClass alloc] initWithLabel:label andKey:key] autorelease];
		
		item.uuid = uuid;
		item.param = [dict stringForKey:@"param" withDefaultValue:@""];
		
		return item;
	}
	else if ( [type isEqualToString:@"ActionImage"] )	
	{
		NSString*				value = [dict stringForKey:@"value" withDefaultValue:@"ActionImageNameMissing"];
		Class					itemClass = [[NSBundle mainBundle] classNamed:value];
		PrefUUIDActionImage*	item = [[[itemClass alloc] initWithLabel:label andKey:key] autorelease];
		
		item.uuid = uuid;
		item.param = [dict stringForKey:@"param" withDefaultValue:@""];
		
		NSString*				defaultImage = [dict objectForKey:@"default-image"];
		if ( defaultImage )
		{
			NSString*			folder = [Folders findUUIDSubFolder:NULL forDomain:domain withUUID:uuid];
			
			item.defaultImage = [UIImage imageWithContentsOfFile:[folder stringByAppendingPathComponent:defaultImage]];
		}
		
		return item;
	}
	else if ( [type isEqualToString:@"Boolean"] )
	{
		PrefBooleanItem*		item = [[[PrefBooleanItem alloc] initWithLabel:label 
									andKey:[uuid stringByAppendingPathComponent:key]
												  andDefaultBooleanValue:[dict booleanForKey:@"value" withDefaultValue:FALSE]] autorelease];
		item.relatedKey = relatedKey;
		return item;
	}
	else if ( [type isEqualToString:@"String"] )
	{
		PrefStringItem*			item = [[[PrefStringItem alloc] initWithLabel:label 
																 andKey:[uuid stringByAppendingPathComponent:key]
												  andDefaultStringValue:[dict stringForKey:@"value" withDefaultValue:@""]] autorelease];
		item.multiline = [dict booleanForKey:@"multiline" withDefaultValue:FALSE];
		
		item.relatedKey = relatedKey;
		return item;
	}
	else if ( [type isEqualToString:@"MultiValue"] )
	{
		PrefMultiValueItem*			item = [[[PrefMultiValueItem alloc] initWithLabel:label 
																andKey:[uuid stringByAppendingPathComponent:key]
																	 andTitles:[dict arrayForKey:@"titles" withDefaultValue:[NSArray array]]
																	 andValues:[dict arrayForKey:@"values" withDefaultValue:[NSArray array]]
														  andDefaultStringValue:[dict stringForKey:@"value" withDefaultValue:@""]] autorelease];
		
		item.relatedKey = relatedKey;
		return item;
	}
	else if ( [type isEqualToString:@"Integer"] )
	{		
		PrefFloatItem*			item = [PrefFloatItem alloc];

		item = [[item initWithLabel:label 
								andKey:[uuid stringByAppendingPathComponent:key] 
						   andMinValue:[dict integerForKey:@"min-value" withDefaultValue:0] 
						   andMaxValue:[dict integerForKey:@"max-value" withDefaultValue:10]
			   andDefaultFloatValue:[dict integerForKey:@"value" withDefaultValue:0]] autorelease];
		item.integerValuesOnly = TRUE;
		item.showValue = [dict booleanForKey:@"show-value" withDefaultValue:TRUE];
		
		item.relatedKey = relatedKey;
		return item;
	}
	else if ( [type isEqualToString:@"Float"] )
	{		
		BOOL					logScale = [dict booleanForKey:@"log-scale" withDefaultValue:FALSE];
		
		PrefFloatItem*			item = [PrefFloatItem alloc];
		if ( !logScale )
		{
			item = [[item initWithLabel:label 
									andKey:[uuid stringByAppendingPathComponent:key] 
									andMinValue:[dict floatForKey:@"min-value" withDefaultValue:0.0f] 
									andMaxValue:[dict floatForKey:@"max-value" withDefaultValue:1.0f]
				   andDefaultFloatValue:[dict floatForKey:@"value" withDefaultValue:0.0f]] autorelease];
		}
		else
		{
			item = [[item initLogarithmicWithLabel:label 
								andKey:[uuid stringByAppendingPathComponent:key] 
						   andMinValue:[dict floatForKey:@"min-value" withDefaultValue:0.0f] 
						   andMaxValue:[dict floatForKey:@"max-value" withDefaultValue:1.0f]
							  andDefaultFloatValue:[dict floatForKey:@"value" withDefaultValue:0.0f]] autorelease];
		}
		item.showValue = [dict booleanForKey:@"show-value" withDefaultValue:TRUE];
		
		item.relatedKey = relatedKey;
		return item;
	}
	else if ( [type isEqualToString:@"Domain"] )
	{
		PrefDomainMultiValueItem*	item = [[[PrefDomainMultiValueItem alloc] initWithLabel:label 
											andKey:[uuid stringByAppendingPathComponent:key]
											andDomain:[dict stringForKey:@"domain" withDefaultValue:@"Games"]
																		  andDefaultValue:[dict stringForKey:@"value" withDefaultValue:@""]] autorelease];
		
		NSString*	order = [dict stringForKey:@"role-search-order" withDefaultValue:NULL];
		if ( order )
		{
			NSMutableArray*			roleSearchOrder = [[[NSMutableArray alloc] init] autorelease];
			
			for ( NSString* tok in [order componentsSeparatedByString:@","] )
			{
				// HACK!!!
				if ( [tok isEqualToString:@"3"] )
				{
					[roleSearchOrder addObject:[NSString stringWithFormat:@"%@:%@", DF_GAMES, uuid]];
				}
				else
				{
					[roleSearchOrder addObject:[NSNumber numberWithInt:atoi([tok UTF8String])]];
				}
			}
			
			item.roleSearchOrder = roleSearchOrder;
		}
		
		item.prefixTitles = [dict arrayForKey:@"prefix-titles" withDefaultValue:NULL];
		item.prefixValues = [dict arrayForKey:@"prefix-values" withDefaultValue:NULL];
		item.suffixTitles = [dict arrayForKey:@"suffix-titles" withDefaultValue:NULL];
		item.suffixValues = [dict arrayForKey:@"suffix-values" withDefaultValue:NULL];
		
		item.relatedKey = relatedKey;
		return item;
	}
	else
	{
		PrefLabelItem*			item = [[[PrefLabelItem alloc] initWithLabel:[NSString stringWithFormat:@"Unknown Type: %@", type] 
															   andKey:NULL] autorelease];
		item.relatedKey = relatedKey;
		return item;
	}
}

@end
