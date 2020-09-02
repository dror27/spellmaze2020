//
//  ParametricGameLevel.m
//  SpellMaze
//
//  Created by Dror Kessler on 10/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <objc/runtime.h>
#import "ParametricGameLevel.h"

#import "Folders.h"
#import "UserPrefs.h"
#import "NSDictionary_TypedAccess.h"
#import "CompoundBoard.h"
#import "GridBoard.h"
#import "GameManager.h"
#import "StringsLanguage.h"
#import "LanguageManager.h"
#import "SymbolForWordLanguage.h"
#import "WordListWordDispenser.h"
#import	"GridBoardPieceDispenserWords.h"

#import	"CompoundGameBoardLogic.h"
#import	"RandomPlacementGBL.h"
#import	"SpiralBoardOrder.h"
#import	"RandomBoardOrder.h"
#import	"ListBoardOrder.h"
#import	"SnakeBoardOrder.h"
#import	"OrderNudgeGBL.h"
#import	"PieceFaderGBL.h"
#import	"CrossPieceDisabler.h"
#import	"PieceDecoratorGBL.h"
#import	"ViewTransformerGBL.h"

#import "UserPrefsUPL.h"
#import "UUIDPropsUPL.h"
#import "NSDictionary_TypedAccess.h"

#import "AuctionSymbolDispenser.h"

@interface ParametricGameLevel (Privates)
-(void)loadFromProps:(NSDictionary*)props;
-(void)initCode;
-(void)loadCode;
-(NSString*)ukey:(NSString*)key;

-(void)boolPref:(id)target sel:(SEL)selector key:(NSString*)key;
-(void)intPref:(id)target sel:(SEL)selector key:(NSString*)key;
-(void)floatPref:(id)target sel:(SEL)selector key:(NSString*)key;
-(void)stringPref:(id)target sel:(SEL)selector key:(NSString*)key;

-(id<UserPrefsLayer>)rebuildUPL;
@end

#define		U(s)	([self ukey:(s)])

@implementation ParametricGameLevel
@synthesize upl = _upl;

-(void)dealloc
{
	[_upl release];
	
	[super dealloc];
}

-(id)initWithProps:(NSDictionary*)props
{
	if ( self = [super init] )
	{
		// setup initial preferences layer
		self.upl = [[[UserPrefsUPL alloc] init] autorelease];
		
		// init some fields
		[self loadFromProps:props];
		self.props = props;
		
		// execute init code
		[self initCode];
	}
	return self;
}

-(void)loadGame
{
	if ( state != INIT )
		return;
	
	[super loadGame];
	
	// execute load code
	[self loadCode];
	
	state = LOADED;
}

-(void)initCode
{
	if ( [_upl hasKey:[self ukey:@"lang_game"]] )
		self.loadDefaultLanguage = FALSE;
	else if ( [_props hasKey:@"lang_game"] )
		self.loadDefaultLanguage = FALSE;
}

-(void)loadCode
{
	// language might have changed, rebuild upl
	self.upl = [self rebuildUPL];
	
	// language
	BOOL		langChanged = FALSE;
    if ( [_upl hasKey:U(@"lang_game")] )
	{
        NSString*	langGame = [_upl getString:U(@"lang_game") withDefault:@""];
		
		if ( [langGame isEqualToString:@"[Game]"] )
			self.language = [[GameManager currentGameLevelSequence] language];
		else if ( [langGame isEqualToString:@"[Global]"] )
			self.language = [LanguageManager getNamedLanguage:@""];
		else if ( [langGame isEqualToString:@"[List]"] )
		{
			NSString*			wordList = [_upl getString:U(@"lang_word_list") withDefault:@""];
			StringsLanguage*	l = [[[StringsLanguage alloc] initWithStringsString:wordList] autorelease];
			l.name = @"List";
			self.language = l;
		}
		else
			self.language = [LanguageManager getNamedLanguage:langGame];
		
		langChanged = TRUE;
	}
    if ( [_upl getBoolean:U(@"lang_tutorial") withDefault:FALSE] ) 
	{
		int		page = [_upl getInteger:U(@"lang_tutorial_page") withDefault:0];
		int		pages = [_upl getInteger:U(@"lang_tutorial_pages") withDefault:1];
	    
		if ( page )
			self.language = [LanguageManager tutorialLanguageFor:self.language];
		else
			self.language = [LanguageManager tutorialPageLanguageFor:self.language withPage:page outOfPages:pages];
		
		langChanged = TRUE;
    }
    if ( [_upl getBoolean:U(@"lang_symbols") withDefault:FALSE] ) 
	{
		self.language = [[[SymbolForWordLanguage alloc] initWithBaseLanguage:self.language] autorelease];
		langChanged = TRUE;
	}
	
	// language might have changed, rebuild upl
	if ( langChanged )
		self.upl = [self rebuildUPL];
	
	// global
	[self boolPref:self sel:@selector(setAllowPlayPause:) key:@"allow_play_pause"];
    [self boolPref:self sel:@selector(setAllowShowHint:) key:@"allow_show_hint"];
    [self boolPref:self sel:@selector(setAllowAddWords:) key:@"allow_add_words"];
	[self boolPref:self sel:@selector(setAllowDupWords:) key:@"allow_dup_words"];
    [self intPref:self sel:@selector(setMinWordSize:) key:@"valid_min_word_size"];
	[self floatPref:self sel:@selector(setScoreFactor:) key:@"score_factor"];
	[self intPref:self sel:@selector(setGameOverGrace:) key:@"game_over_grace"];
	[self intPref:self sel:@selector(setGameWonGrace:) key:@"game_won_grace"];
	[self boolPref:self sel:@selector(setShowSummarySplash:) key:@"show_summary_splash"];
	[self boolPref:self sel:@selector(setAutorun:) key:@"autorun"];
	[self intPref:self sel:@selector(setAutoMaxWordSizeBehavior:) key:@"auto_max_word_size_behavior"];
	[self boolPref:self sel:@selector(setAutoValidWordWipe:) key:@"auto_valid_word_wipe"];
	[self boolPref:self sel:@selector(setShowLanguageBackground:) key:@"show_language_background"];
	[self intPref:self sel:@selector(setBoardFullWarnBudget:) key:@"board_full_warn_budget"];
	[self intPref:self sel:@selector(setBoardFullWarnCost:) key:@"board_full_warn_cost"];
	
	// board
    if ( [_upl getBoolean:[self ukey:@"board_override"] withDefault:FALSE] ) 
	{
		id<Board>	board;
        int			rows = [_upl getInteger:[self ukey:@"board_rows"] withDefault:6];
		int			columns = [_upl getInteger:[self ukey:@"board_columns"] withDefault:6];
        NSString*	formula = [_upl getString:[self ukey:@"board_formula"]  withDefault: @""];
		
		if ( [formula length] )
			board = [CompoundBoard boardByFormula:formula];
		else
			board = [[[GridBoard alloc] initWithWidth:columns andHeight:rows] autorelease];
 
		self.board = board;
		board.level = self;

		formula = [_upl getString:[self ukey:@"hint_board_formula"]  withDefault: @""];
		if ( [formula length] )
		{
			self.hintBoard = [CompoundBoard boardByFormula:formula];
			self.hintBoard.level = self;
		}
	}
	
	// dispenser
    if ( [_upl getBoolean:U(@"dispenser_word_by_word") withDefault:FALSE] )
	{
		NSArray*				words = [self.language getAllWords];
		WordListWordDispenser*	wordDispenser = [[[WordListWordDispenser alloc] initWithWords:words 
																			  andRandomOrder:[_upl getBoolean:U(@"dispenser_reorder") withDefault:FALSE]] autorelease];
		GridBoardPieceDispenserWords* pieceDispenser = [[[GridBoardPieceDispenserWords alloc] init] autorelease];
		pieceDispenser.wordDispenser = wordDispenser;
		pieceDispenser.dispensingTickPeriod = 0.5;
		pieceDispenser.interWordTickPeriod = 0.5;
		pieceDispenser.scrambleWordSymbols = [_upl getBoolean:U(@"dispenser_scramble") withDefault:FALSE];
		self.dispenser = pieceDispenser;
    }
    if ( [_upl getBoolean:U(@"dispenser_auction") withDefault:FALSE] )
	{
		AuctionSymbolDispenser*	symbolDispenser = [[[AuctionSymbolDispenser alloc] initWithBoard:_board] autorelease];

		[symbolDispenser setAlphabet:[[self language] alphabet]];
		[symbolDispenser setSymbolCount:100];
		
        if ( [_dispenser respondsToSelector:@selector(setSymbolDispenser:)] )
			[_dispenser performSelector:@selector(setSymbolDispenser:) withObject:symbolDispenser];
	}
    [self floatPref:_dispenser sel:@selector(setDispensingTickPeriod:) key:@"dispenser_tick_period"];
    [self floatPref:_dispenser sel:@selector(setBoardFullnessTickPeriodFactor:) key:@"dispenser_fullness_factor"];
    [self floatPref:_dispenser sel:@selector(setBoardFullnessTickPeriodCurve:) key:@"dispenser_fullness_curve"];
    [self floatPref:_dispenser sel:@selector(setBoardProgressTickPeriodFactor:) key:@"dispenser_progress_factor"];
    [self floatPref:_dispenser sel:@selector(setDispenserProgressTickPeriodFactor:) key:@"dispenser_self_progress_factor"];
    if ( [_dispenser respondsToSelector:@selector(symbolDispenser)] )
	{
		id<SymbolDispenser>		symbolDispenser = [_dispenser performSelector:@selector(symbolDispenser)];
		
        [self intPref:symbolDispenser sel:@selector(setSymbolCount:) key:@"dispenser_symbol_count"];
        [symbolDispenser performSelector:@selector(setAlphabet:) withObject:[_language alphabet]];
    }
    if ( [_dispenser respondsToSelector:@selector(setJokerProb:)] )
		[self floatPref:_dispenser sel:@selector(setJokerProb:) key:@"dispenser_joker_prob"];

	// logic
	CompoundGameBoardLogic*	logics = [[[CompoundGameBoardLogic alloc] initWithBoard:_board] autorelease];
	[logics add:[[[RandomPlacementGBL alloc] initWithBoard:_board] autorelease]];
	if ( [_upl getBoolean:U(@"logic_random") withDefault:FALSE] )
	{
		RandomPlacementGBL*		logic = [[[RandomPlacementGBL alloc] initWithBoard:_board] autorelease];
		
		logic.pauseAtWordEnd = [_upl getBoolean:U(@"logic_word_end_pause") withDefault:FALSE];
		logic.alwaysRandomPlacement = TRUE;
        
        [logics add:logic];
    }
	if ( [_upl getBoolean:U(@"logic_line") withDefault:FALSE] )
	{
		RandomPlacementGBL*		logic = [[[RandomPlacementGBL alloc] initWithBoard:_board] autorelease];
		
		logic.alwaysRandomPlacement = FALSE;
		logic.pauseAtWordEnd = TRUE;
        
        [logics add:logic];
    }
	if ( [_upl getBoolean:U(@"logic_nudge") withDefault:FALSE] )
	{
        NSString*		orderName = [_upl getString:U(@"logic_board_order") withDefault:@""];
		id<BoardOrder>	order;
		
		if ( [orderName isEqualToString:@"Spiral"] )
			order = [[[SpiralBoardOrder alloc] initWithGridBoard:_board] autorelease];
		else if ( [orderName isEqualToString:@"Chaos"] )
			order = [[[RandomBoardOrder alloc] initWithGridBoard:_board] autorelease]; 
		else if ( [orderName isEqualToString:@"[List]"] )
		{
			NSString*	orderList = [_upl getString:U(@"logic_order_list") withDefault:NULL];
			
			order = [[[ListBoardOrder alloc] initWithGridBoard:_board andList:orderList] autorelease];
		}
		else
			order = [[[SnakeBoardOrder alloc] initWithGridBoard:_board] autorelease];
		
        OrderNudgeGBL*	logic = [[[OrderNudgeGBL alloc] initWithBoard:_board andBoardOrder:order] autorelease];

        [logics add:logic];
    }
	if ( [_upl getBoolean:U(@"logic_fader") withDefault:FALSE] )
	{
		PieceFaderGBL*		logic = [[[PieceFaderGBL alloc] initWithBoard:_board] autorelease];
		
		logic.fadePace = [_upl getFloat:U(@"logic_fader_pace") withDefault:8.0];
		logic.resetFadeOnValidWord = [_upl getBoolean:U(@"logic_fader_valid_resets") withDefault:TRUE];

        [logics add:logic];
    }
	if ( [_upl getBoolean:U(@"logic_disabler") withDefault:FALSE] )
	{
		CrossPieceDisabler*	logic = [[[CrossPieceDisabler alloc] initWithBoard:_board] autorelease];
		
		logic.progressive = [_upl getBoolean:U(@"logic_disabler_progressive") withDefault:FALSE];
		logic.highlight = [_upl getBoolean:U(@"logic_disabler_highlight") withDefault:FALSE];
		logic.type = [_upl getInteger:U(@"logic_disabler_pattern") withDefault:0];

		[logics add:logic];
	}
	if ( [_upl getBoolean:U(@"logic_decorator") withDefault:FALSE] )
	{
		PieceDecoratorGBL*	logic = [[[PieceDecoratorGBL alloc] initWithBoard:_board] autorelease];
		
		if ( [_upl hasKey:U(@"logic_decorator_apple_prob")] )
			[logic setDecoration:DECORATOR_APPLE withProb:[_upl getFloat:U(@"logic_decorator_apple_prob") withDefault:0.1]];
		if ( [_upl hasKey:U(@"logic_decorator_coin_prob")] )
			[logic setDecoration:DECORATOR_COIN withProb:[_upl getFloat:U(@"logic_decorator_coin_prob") withDefault:0.05]];
		if ( [_upl hasKey:U(@"logic_decorator_bomb_prob")] )
			[logic setDecoration:DECORATOR_BOMB withProb:[_upl getFloat:U(@"logic_decorator_bomb_prob") withDefault:0.05]];

		[logics add:logic];
    }
	if ( [_upl getBoolean:U(@"logic_viewtrans") withDefault:FALSE] )
	{
		ViewTransformerGBL*	logic = [[[ViewTransformerGBL alloc] initWithBoard:_board] autorelease];
		
        [self intPref:logic sel:@selector(setRotationSlices:) key:@"logic_viewtrans_slices"];
        [self stringPref:logic sel:@selector(setRotationEvent:) key:@"logic_viewtrans_event"];
        [self boolPref:logic sel:@selector(setResetAtEnd:) key:@"logic_viewtrans_reset_at_end"];
        [self boolPref:logic sel:@selector(setFollowDevice:) key:@"logic_viewtrans_follow_device"];
        [self intPref:logic sel:@selector(setDeviceLPF:) key:@"logic_viewtrans_device_lpf"];
        [self intPref:logic sel:@selector(setDeviceSlices:) key:@"logic_viewtrans_device_slices"];
		
		[logics add:logic];
    }
	if ( [logics count] )
		self.logic = logics;

	// hint
    [self intPref:self sel:@selector(setShowHintDelay:) key:@"show_hint_delay"];
    [self intPref:self sel:@selector(setBetweenHintDelay:) key:@"between_hint_delay"];
    [self boolPref:self sel:@selector(setSpeakHintWord:) key:@"speak_hint_word"];
    [self boolPref:self sel:@selector(setShowHintWord:) key:@"show_hint_word"];
    [self boolPref:self sel:@selector(setShowHintImage:) key:@"show_hint_image"];
    [self boolPref:self sel:@selector(setShowHintText:) key:@"show_hint_text"];
    [self boolPref:self sel:@selector(setShowHintPieces:) key:@"show_hint_pieces"];
    [self intPref:self sel:@selector(setHintMaxWordSize:) key:@"hint_max_word_size"];
	[self boolPref:self sel:@selector(setJokerImageHints:) key:@"joker_image_hints"];
	[self boolPref:self sel:@selector(setJokerImageRewards:) key:@"joker_image_rewards"];
	[self boolPref:self sel:@selector(setShowLanguageBackground:) key:@"show_language_background"];
	[self boolPref:self sel:@selector(setLevelEndMenu:) key:@"level_end_menu"];
    [self intPref:self sel:@selector(setLevelEndContinueRemainingWordCountThreshold:) key:@"lem_continue_threshold"];
    
	// reward
    [self boolPref:self sel:@selector(setShowRewardImage:) key:@"show_reward_image"];
    [self boolPref:self sel:@selector(setShowRewardText:) key:@"show_reward_text"];
    [self boolPref:self sel:@selector(setSpeakRewardWord:) key:@"speak_reward_word"];
    
	// flash image
    [self floatPref:self sel:@selector(setFlashAttackDuration:) key:@"flash_attack_duration"];
    [self floatPref:self sel:@selector(setFlashAttackAlpha:) key:@"flash_attack_alpha"];
    [self floatPref:self sel:@selector(setFlashSustainDuration:) key:@"flash_sustain_duration"];
    [self floatPref:self sel:@selector(setFlashSustainAlpha:) key:@"flash_sustain_alpha"];
    [self floatPref:self sel:@selector(setFlashDecayDuration:) key:@"flash_decay_duration"];
    [self floatPref:self sel:@selector(setFlashDecayAlpha:) key:@"flash_decay_alpha"];
    
	// rush (precharge)
    [self stringPref:self sel:@selector(setRushSymbols:) key:@"rush_symbols"];
    [self intPref:self sel:@selector(setRushWords:) key:@"rush_words"];
    [self intPref:self sel:@selector(setRushMinWordSize:) key:@"rush_min_word_size"];
    [self intPref:self sel:@selector(setRushMaxWordSize:) key:@"rush_max_word_size"];
    [self floatPref:self sel:@selector(setRushDispensingFactor:) key:@"rush_dispensing_factor"];
}

-(void)loadFromProps:(NSDictionary*)props
{
	self.uuid = [props objectForKey:@"uuid"];
	self.title = [props objectForKey:@"name"];
	self.shortDescription = [props objectForKey:@"description"];	
	
	self.helpSplashPanel = [SplashPanel splashPanelWithProps:[props objectForKey:@"help-splash"] 
													 forUUID:_uuid inDomain:DF_LEVELS withDelegate:self];
}

-(NSString*)ukey:(NSString*)key
{
	return [_uuid stringByAppendingPathComponent:key];
}

-(void)anyPref:(id)target sel:(SEL)selector key:(NSString*)key value:(id)value
{
	if ( !value )
		value = [_props objectForKey:key];
	
	if ( value )
		[target performSelector:selector withObject:value];
}

-(void)boolPref:(id)target sel:(SEL)selector key:(NSString*)key
{
	NSString*		ukey = [self ukey:key];
	NSNumber*		value = NULL;
	
	if ( [_upl hasKey:ukey] )
		value = [NSNumber numberWithBool:[_upl getBoolean:ukey withDefault:FALSE]];
	if ( !value )
		value = [_props objectForKey:key];
	
	if ( value )
	{
		Method			method = NULL;
		for ( Class c = [target class] ; c != NULL && method == NULL ; c = class_getSuperclass(c) )
			method = class_getInstanceMethod(c, selector);
		
		IMP				imp = method_getImplementation(method);
		int				v = [value boolValue];
		id				arg = *((id*)(&v));
		
        [target performSelector:selector withObject:v];
	}
}

-(void)intPref:(id)target sel:(SEL)selector key:(NSString*)key
{
	NSString*		ukey = [self ukey:key];
	NSNumber*		value = NULL;
	
	if ( [_upl hasKey:ukey] )
		value = [NSNumber numberWithInt:[_upl getInteger:ukey withDefault:0]];	
	if ( !value )
		value = [_props objectForKey:key];
	
	if ( value )
	{
		Method			method = NULL;
		for ( Class c = [target class] ; c != NULL && method == NULL ; c = class_getSuperclass(c) )
			method = class_getInstanceMethod(c, selector);
		
		IMP				imp = method_getImplementation(method);
		int				v = [value intValue];
		id				arg = *((id*)(&v));
        
        [target performSelector:selector withObject:v];
	}
}

-(void)floatPref:(id)target sel:(SEL)selector key:(NSString*)key
{
	NSString*		ukey = [self ukey:key];
	NSNumber*		value = NULL;
	
	if ( [_upl hasKey:ukey] )
		value = [NSNumber numberWithFloat:[_upl getFloat:ukey withDefault:0.0]];
	if ( !value )
		value = [_props objectForKey:key];
	
	if ( value )
	{
		Method			method = NULL;
		for ( Class c = [target class] ; c != NULL && method == NULL ; c = class_getSuperclass(c) )
			method = class_getInstanceMethod(c, selector);

		IMP				imp = method_getImplementation(method);
		float			v = [value floatValue];
		id				arg = *((id*)(&v));

        [target performSelector:selector withObject:(int)v];
	}
}

-(void)stringPref:(id)target sel:(SEL)selector key:(NSString*)key
{
	NSString*		ukey = [self ukey:key];
	id				value = NULL;
	
	if ( [_upl hasKey:ukey] )
		value = [_upl getString:ukey withDefault:@""];
	
	[self anyPref:target sel:selector key:key value:value];
}

-(id<UserPrefsLayer>)rebuildUPL
{
	id<UserPrefsLayer>		upl = [[[UserPrefsUPL alloc] init] autorelease];
	
	NSArray*				langLayers = [[_language props] objectForKey:@"game-props-layers"];
	if ( langLayers )
		for ( NSDictionary* layer in langLayers )
		{
			for ( NSString* key in [[layer stringForKey:@"key" withDefaultValue:@""] componentsSeparatedByString:@","] )
			{
				if ( [key isEqualToString:@"[All]"] || [key isEqualToString:_uuid] )
				{
					upl = [[[UUIDPropsUPL alloc] initWithUUID:_uuid andProps:[layer objectForKey:@"props"] andNextLayer:upl] autorelease];
				}
			}
		}
	
	return upl;
}

@end
