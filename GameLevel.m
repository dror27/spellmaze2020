//
//  GameLevel.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "GameLevel.h"
#import	"GameLevelView.h"
#import "Board.h"
#import	"StringsLanguage.h"
#import	"RandomSymbolDispenser.h"
#import "SymbolPiece.h"
#import "GridBoard.h"
#import	"GridBoardPieceDispenserSymbols.h"
#import "GridBoardPieceDispenserWords.h"
#import "WordListWordDispenser.h"
#import "CSetWrapper.h"
#import "ArrayPiecesHint.h"
#import "RandomPlacementGBL.h"
#import "SimpleBoardOrder.h"
#import "OrderNudgeGBL.h"
#import "SnakeBoardOrder.h"
#import "SpiralBoardOrder.h"
#import "RandomBoardOrder.h"
#import "PieceFaderGBL.h"
#import "CompoundGameBoardLogic.h"
#import "CrossPieceDisabler.h"
#import "NSString_Reverse.h"
#import "TextSpeaker.h"
#import "UserPrefs.h"
#import "ScoreWidget.h"
#import "GameLevel_WordInfo.h"
#import "UIDevice_AvailableMemory.h"
#import "LanguageManager.h"
#import "BoardContentsWeightedSymbolDispenser.h"
#import "WordCountBPF.h"
#import "GoalSeekingSymbolDispenser.h"
#import "EnvelopeDynamics.h"
#import "PieceDecoratorGBL.h"
#import "JokerUtils.h"
#import "SystemUtils.h"
#import "PieceView.h"
#import "GameLevel.h"
#import "ScoresDatabase.h"
#import "GameLevelSequence.h"
#import "BrandManager.h"
#import "Wallet.h"
#import "PhraseWordValidator.h"
#import "NSMutableArray_Shuffle.h"
#import "NSDictionary_TypedAccess.h"
#import "AuctionSymbolDispenser.h"
#import "SymbolPieceView.h"
#import "CellView.h"
#import "RoleManager.h"
#import "L.h"
#import "RTLUtils.h"

static BOOL		askToAddWords_Global = TRUE;
static BOOL		askToAddWords_Level = TRUE;

#define			DEFAULT_BOARD_SIZE					6
#define			SHOW_SCORE_IN_SUMMARY_SPLASH		FALSE

#define			OLD_REWARD_CLEAR_SECS				3

//#define			DEBUG_FORCE_INIT_BLACKLIST_SIZE		7
#define			AUTORUN_DELAY		0

#define			CHK_DEALLOC		{if (state >= DEALLOCATED1) return;}
#define			CHK_DEALLOC_FALSE		{if (state >= DEALLOCATED1) return FALSE;}

#define			DEFAULT_BOARD_FULL_WARN_BUDGET		150
#define			DEFAULT_BOARD_FULL_WARN_COST		15

//#define			DUMP_VALID_SELECTED_WORDS


@interface GameLevel (Privates)
-(void)updateCurrentWord;
-(void)processValidWord:(NSString*)word showWord:(BOOL)showWord;
-(void)onReplayTick;
-(void)alertInvalidWordCandidate:(NSString*)word withInfo:(GameLevel_WordInfo*)wordInfo;
-(BOOL)alertAddCandidates;
-(BOOL)alertApproveWord;
-(EnvelopeDynamics*)flashEnvelope;
-(NSMutableString*)buildRushSymbolsForDispenser;
-(void)speak:(NSString*)word;
-(int)currentWordPiecesNonJokerCount;
-(BOOL)removeAllJokerHints:(NSString*)word;
-(NSSet*)getCurrentWordJokerWords;
-(BOOL)joker:(id<Piece>)p validForWord:(NSString*)w;
-(int)boardWordCount;
-(void)clearBoard;
-(NSString*)spelledWord:(NSString*)word;
-(void)updateHintWord;
-(void)preloadSymbolViews;
-(int)remainingCount;
-(void)addWord:(NSString*)word toBlackList:(BOOL)addToBlackList andHintBlackList:(BOOL)addToHintBlackList;
@end

//HACK
//#define MEASURE
#ifdef	MEASURE
static clock_t		startedAt;
#endif

//#define		ALLOC_COUNT
#ifdef		ALLOC_COUNT
static int			initCount;
static int			deallocCount;
#endif

//#define		DUMP_THREAD

@implementation GameLevel

@synthesize loadDefaultLanguage;
@synthesize loadDefaultBoard;
@synthesize loadDefaultDispenser;
@synthesize loadDefaultLogic;

@synthesize board = _board;
@synthesize language = _language;
@synthesize wordValidator = _wordValidator;
@synthesize dispenser = _dispenser;
@synthesize tickTimer = _tickTimer;
@synthesize view = _view;
@synthesize piecesHint = _piecesHint;
@synthesize hintWord = _hintWord;

@synthesize eventsTarget = _eventsTarget;
@synthesize soundTheme = _soundTheme;
@synthesize title = _title;
@synthesize shortDescription = _shortDescription;
@synthesize minWordSize;
@synthesize currentWordPieces = _currentWordPieces;
@synthesize logic = _logic;

@synthesize gameOverGrace;
@synthesize gameWonGrace;
@synthesize pausedGrace;
@synthesize idleToHintGrace;

@synthesize allowDupWords;

@synthesize selectedWords = _selectedWords;
@synthesize uuid = _uuid;


@synthesize scoreWidget = _scoreWidget;

@synthesize showWordImageOnDispensed;
@synthesize showWordImageOnValid;
@synthesize speakWordOnDispensed;

@synthesize replayValidWord;
@synthesize allowReselectPartialDeselect;
@synthesize allowAddWords;

@synthesize addWordCandidate = _addWordCandidate;
@synthesize pauseOnWordCount;
@synthesize pauseOnWordCountIncrement;

@synthesize blackList = _blackList;
@synthesize hintBlackList = _hintBlackList;

@synthesize allowPlayPause;
@synthesize allowShowHint;

// new preferences model starts here
@synthesize showHintDelay;
@synthesize betweenHintDelay;
@synthesize speakHintWord;
@synthesize showHintWord;
@synthesize showHintImage;
@synthesize showHintText;
@synthesize showHintPieces;
@synthesize hintMaxWordSize;

@synthesize speakRewardWord;
@synthesize showRewardImage;
@synthesize showRewardText;

@synthesize flashAttackDuration;
@synthesize flashAttackAlpha;
@synthesize flashSustainDuration;
@synthesize flashSustainAlpha;
@synthesize flashDecayDuration;
@synthesize flashDecayAlpha;

@synthesize rushSymbols = _rushSymbols;
@synthesize rushWords;
@synthesize rushMinWordSize;
@synthesize rushMaxWordSize;
@synthesize rushDispensingFactor;

@synthesize helpSplashPanel = _helpSplashPanel;
@synthesize textSplashPanel = _textSplashPanel;
@synthesize summarySplashPanel = _summarySplashPanel;

@synthesize props = _props;
@synthesize seq = _seq;

@synthesize state;

@synthesize commitWords = _commitWords;
@synthesize commitWordCandidate = _commitWordCandidate;

@synthesize showSummarySplash;
@synthesize scoreFactor;
@synthesize autorun;
@synthesize	autoMaxWordSizeBehavior;
@synthesize autoValidWordWipe;

@synthesize stateWhenSuspended = _stateWhenSuspended;

@synthesize jokerImageHints;
@synthesize jokerImageRewards;
@synthesize showLanguageBackground;
@synthesize levelEndMenu;
@synthesize levelEndContinueRemainingWordCountThreshold;
@synthesize initialBlackList = _initialBlackList;

@synthesize hintBoard = _hintBoard;

@synthesize boardFullWarnBudget;
@synthesize boardFullWarnLeft;
@synthesize boardFullWarnCost;

@synthesize fastGame;

-(id)init
{
	if ( self = [super init] )
	{
		state = INIT;

		// default title/description
		self.title = LOC(@"Title");
		self.shortDescription = LOC(@"Short Description");
		self.uuid = @"";
		
		// default load defaults
		loadDefaultLanguage = TRUE;
		loadDefaultBoard = TRUE;
		loadDefaultDispenser = TRUE;
		loadDefaultLogic = TRUE;
		
#ifdef	ALLOC_COUNT
		initCount++;
		NSLog(@"[GameLevel-%p] init: init/dealloc = %d/%d", self, initCount, deallocCount);
#endif
		
		scoreFactor = 1;
	}
	
	return self;
}

#ifdef ALLOC_COUNT
-(id)retain
{
	//NSLog(@"[GameLevel-%p] retain", self);
	return [super retain];
}
-(void)release
{
	//NSLog(@"[GameLevel-%p] release", self);
	[super release];
}
-(id)autorelease
{
	//NSLog(@"[GameLevel-%p] autorelease", self);
	return [super autorelease];
}
#endif

-(void)dealloc
{
	//NSLog(@"[GameLevel-%p] dealloc (%@)", self, self.title);
	state = DEALLOCATED1;
	
#ifdef	ALLOC_COUNT
	deallocCount++;
	NSLog(@"[GameLevel-%p] dealloc: init/dealloc = %d/%d", self, initCount, deallocCount);
#endif

	if ( _tickTimer && [_tickTimer isValid] )
		[_tickTimer invalidate];
	
	[_board setLevel:nil];
	[_board release];
	
	[_language release];
	[_wordValidator release];
	
	[_dispenser setTarget:nil];
	[_dispenser release];
	
	[_tickTimer release];
	
	[_view setModel:nil];
	[_view release];
	
	[_piecesHint release];
	[_hintWord release];
	
	[_soundTheme release];
	[_title release];
	[_shortDescription release];
	[_currentWordPieces release];
	[_logic release];
	[_selectedWords release];
	[_uuid release];
	
	[_scoreWidget setEventsTarget:nil];
	[_scoreWidget release];
	
	[_addWordCandidate release];
	[_blackList release];
	[_hintBlackList release];
	[_rushSymbols release];
	
	[_helpSplashPanel setDelegate:nil];
	[_helpSplashPanel release];
	
	[_textSplashPanel setDelegate:nil];
	[_textSplashPanel release];
	
	[_summarySplashPanel setDelegate:nil];
	[_summarySplashPanel release];
	
	[_props release];
	[_commitWords release];
	[_commitWordCandidate release];
	[_stateWhenSuspended release];
	
	[_initialBlackList release];
	
	[_hintBoard release];
	
	state = DEALLOCATED2;
	[super dealloc];
	state = DEALLOCATED3;
}

-(void)loadGame
{
	if ( state != INIT )
		return;
	
	// general settings
	gameOverGrace = 15;
	gameWonGrace = 15;
	pausedGrace = 10;
	idleToHintGrace = 10;
	self.piecesHint = NULL;
	self.soundTheme = [SoundTheme singleton];
	hintsEnabled = TRUE;
	self.scoreWidget = [[[ScoreWidget alloc] init] autorelease];
	[_scoreWidget setEventsTarget:self];
	allowDupWords = FALSE;
	self.selectedWords = [[[NSMutableDictionary alloc] init] autorelease];
	allowReselectPartialDeselect = FALSE;
	allowAddWords = TRUE;
	self.blackList = [[[CSetWrapper alloc] init] autorelease];
	self.hintBlackList = [[[CSetWrapper alloc] init] autorelease];
	showWordImageOnValid = TRUE;
	showHintImage = TRUE;
	showHintText = FALSE;
	allowPlayPause = FALSE;
	allowShowHint = FALSE;
	
	levelEndMenu = FALSE;
	levelEndContinueRemainingWordCountThreshold = 0;
	
	boardFullWarnBudget = DEFAULT_BOARD_FULL_WARN_BUDGET;
	boardFullWarnCost = DEFAULT_BOARD_FULL_WARN_COST;
	
	// preferences defaults
	showHintDelay = 6;
	betweenHintDelay = 7;
	speakHintWord = TRUE;
	showHintWord = TRUE;
	showHintPieces = FALSE;
	jokerImageHints = FALSE;
	hintMaxWordSize = 6;
	showSummarySplash = TRUE;
	
	showRewardImage = TRUE;
	showRewardText = TRUE;
	speakRewardWord = TRUE;
	
	flashAttackDuration = 0.20;
	flashAttackAlpha = 1.0;
	flashSustainDuration = 0.2;
	flashSustainAlpha = 1.0;
	flashDecayDuration = 0.2;
	flashDecayAlpha = 0;
	
	idleToHintGrace = showHintDelay;
	
	self.rushSymbols = @"";
	rushWords = 1;
	rushMinWordSize = 3;
	rushMaxWordSize = 4;
	rushDispensingFactor = 3;
	
	showHintWordCount = TRUE;
	
	
	// defualt language
	if ( loadDefaultLanguage )
		self.language = [LanguageManager getNamedLanguage: NULL];
	
	// default board
	if ( loadDefaultBoard )
	{
		int			cols = -1;
		int			rows = -1;
		
		// get dimensions from language
		NSNumber*	skinValue;
		if ( [_language respondsToSelector:@selector(getSkinProp:withDefaultValue:)] )
		{
			if ( skinValue = [_language performSelector:@selector(getSkinProp:withDefaultValue:) withObject:@"grid-cell-columns" withObject:NULL] )
				cols = [skinValue intValue];
			if ( skinValue = [_language performSelector:@selector(getSkinProp:withDefaultValue:) withObject:@"grid-cell-rows" withObject:NULL] )
				rows = [skinValue intValue];
		}
		
		// consult brand?
		if ( cols < 0 )
			cols = [[BrandManager currentBrand] globalInteger:@"skin/props/grid-cell-columns" withDefaultValue:DEFAULT_BOARD_SIZE];
		if ( rows < 0 )
			rows = [[BrandManager currentBrand] globalInteger:@"skin/props/grid-cell-rows" withDefaultValue:DEFAULT_BOARD_SIZE];

		if ( CHEAT_ON(CHEAT_WIDE_CELLS) )
			cols /= 2;
		
		self.board = [[[GridBoard alloc] initWithWidth:cols andHeight:rows] autorelease];
		_board.level = self;
	}
	
	// default dispenser (piece, underlying symbol)
	if ( loadDefaultDispenser )
	{
		RandomSymbolDispenser*		sd;
		if ( [_language wordCount] > 2000000 /* never */ )
		{
			sd = [[[BoardContentsWeightedSymbolDispenser alloc] initWithBoard:self.board] autorelease];
		}
		else
		{
#ifdef	 OLD_GOAL_BASE_DISPENSER
			WordCountBPF* bpf = [[[WordCountBPF alloc] init] autorelease];
			GoalSeekingSymbolDispenser* sd1 = [[[GoalSeekingSymbolDispenser alloc] init] autorelease];
			[sd1 setMaxLookahead:1];
			sd = sd1;
			[sd1 setBoard:_board];
			[sd1 setBoardPotentialFunction:bpf];
#else
			AuctionSymbolDispenser*		sd1 = [[[AuctionSymbolDispenser alloc] initWithBoard:_board] autorelease];
			sd = sd1;
#endif
			
		}
		[sd setAlphabet:[[self language] alphabet]];
		[sd setSymbolCount:100];
		GridBoardPieceDispenserSymbols* pd = [[[GridBoardPieceDispenserSymbols alloc] init] autorelease];
		[pd setSymbolDispenser:sd];
		[pd setDispensingTickPeriod:1.5];
		self.dispenser = pd;
	}
	
	// load default logic
	if ( loadDefaultLogic )
	{
		self.logic = [[[RandomPlacementGBL alloc] initWithBoard: _board] autorelease];
	}
	
	// current word
	self.currentWordPieces = [[[NSMutableArray alloc] init] autorelease];
}


-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( state == INIT )
		[self loadGame];
	
	if ( self.view == NULL )
		self.view = [[[GameLevelView alloc] initWithFrame:frame andModel:self] autorelease];
	
	return self.view;
}

-(void)startGame
{	
	if ( state != INIT && state != LOADED && state != START_SPLASH )
	{
		NSLog(@"[GameLevel] ERROR - startGame called in an invalid state: %d", state);
		return;
	}
	
	if ( state != START_SPLASH )
	{
	
#ifdef DEBUG_FORCE_INIT_BLACKLIST_SIZE
		if ( !_initialBlackList )
		{
			NSMutableArray*		words = [NSMutableArray array];
			
			for ( NSString* word in [_language getAllWords] )
				if ( [word length] <= DEBUG_FORCE_INIT_BLACKLIST_SIZE )
					[words addObject:word];
			
			self.initialBlackList = [NSSet setWithArray:words];
		}
#endif
	
		// load initial blacklist
		if ( _initialBlackList )
		{
#ifdef DUMP_VALID_SELECTED_WORDS
			NSLog(@"initiate blackList: %@", _initialBlackList);
#endif
			hintMaxWordSize = [_language maxWordSize];
			rushMaxWordSize = hintMaxWordSize;
			
			for ( NSString* word in _initialBlackList )
				[self addWord:word toBlackList:TRUE andHintBlackList:TRUE];				
			CSet_RemoveDuplicates(_blackList.cs);
			CSet_RemoveDuplicates(_hintBlackList.cs);
		}
		
		// move words from wallet into hint back list.
		// if level has level-end-menu, add to black list as well (by default)
		[[Wallet singleton] checkNotAllLanguageWordsHintBlackWords:_language];
		for ( NSString* word in [[Wallet singleton] allHintBlackWords] )
			[self addWord:word toBlackList:levelEndMenu andHintBlackList:TRUE];
		CSet_RemoveDuplicates(_blackList.cs);
		CSet_RemoveDuplicates(_hintBlackList.cs);		
		
		// re-wire to board (in case it has chnanged)
		for ( NSObject* obj in [NSArray arrayWithObjects:_dispenser, _logic, NULL] )
			if ( [obj respondsToSelector:@selector(setBoard:)] )
				[obj performSelector:@selector(setBoard:) withObject:_board];
		
		self.stateWhenSuspended = [NSMutableArray array];
		
		if ( state == INIT )
			[self loadGame];
		
		boardFullWarnLeft = boardFullWarnBudget;
		boardWordCountResult = -1;
	}
	
	if ( state == LOADED && _helpSplashPanel && [_helpSplashPanel autoShow] && ![_initialBlackList count] )
	{
		state = START_SPLASH;
		
		[self showHelpSplash];
		
		[self.soundTheme wordValid:NULL fromLanguage:NULL];
		return;
	}
	
	// make sure we have a word validator. if none, validate directly against language
	if ( !_wordValidator )
	{
		/*
		if ( [_dispenser isKindOfClass:[GridBoardPieceDispenserWords class]] )
			self.wordValidator = [[[PhraseWordValidator alloc] init] autorelease];
		else
		 */
			self.wordValidator = _language;
	}
	
	// install some cheats
	allowDupWords |= CHEAT_ON(CHEAT_REPEAT_WORDS_IN_LEVEL);
	allowPlayPause |= CHEAT_ON(CHEAT_PLAY_PAUSE_AT_WILL);
	allowShowHint |= CHEAT_ON(CHEAT_SHOW_HINTS_AT_WILL);
	levelEndMenu |= CHEAT_ON(CHEAT_LEVEL_END_MENU);
	askToAddWords_Level = [_language allowAddWord];
	
	// setup score widget conf
	ScoresDatabase*		sdb = [ScoresDatabase singleton];
	_scoreWidget.allowPlayPause = allowPlayPause;
	_scoreWidget.allowShowHint = allowShowHint;
	_scoreWidget.scoreDisplayOffset = -[sdb globalScore] + [sdb bestScoreForGame:[_seq uuid] onLanguage:[_language uuid]];
	if ( !_initialBlackList || ![_initialBlackList count] )
	_scoreWidget.scoreDisplayOffset -= [sdb maxScoreForLevel:_uuid onLanguage:[_language uuid]];
	
	// setup rush delivery
	if ( [_dispenser isKindOfClass: [GridBoardPieceDispenserSymbols class]] )
	{
		GridBoardPieceDispenserSymbols*		sd = (GridBoardPieceDispenserSymbols*)_dispenser;
		
		sd.rushDispensingFactor = rushDispensingFactor;
		sd.symbolDispenser.rushSymbols = [self buildRushSymbolsForDispenser];
	}
	
	// make sure we can hint words
	if ( hintMaxWordSize && (hintMaxWordSize < minWordSize) )
		hintMaxWordSize = minWordSize + 2;
	
	gameOverGraceLeft = gameOverGrace;
	idleToHintGrace = showHintDelay;
	state = PLAYING;
	[_dispenser startDispensing:self andContext:NULL];
	
	self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onTimer) userInfo:nil repeats:YES]; 		
	
	[_scoreWidget setMessage1:[self title]];
	[_scoreWidget setMessage2:[self shortDescription]];
	if ( allowPlayPause )
		[_scoreWidget setPlayState:PS_PLAYING];
	if ( allowShowHint )
		[_scoreWidget setGameAction:GA_HINT];
	
	// force rapid hint generation in autorun mode
	autorun |= [SystemUtils autorun];
	autorunAccumulateScore = [SystemUtils autorunAccumulateScore];
	if ( autorun )
	{
		idleToHintGrace = betweenHintDelay = showHintDelay = AUTORUN_DELAY;
		showHintWord = TRUE;
	}
	
	/*
	if ( _initialBlackList )
	{
		int		blackListCount = [_initialBlackList count];
		int		totalCount = [_language getWordCount:minWordSize withMaxSize:0];
		
		[_scoreWidget setMessage1:LOC(@"Continuing ...")];
		[_scoreWidget setMessage2:[NSString stringWithFormat:LOC(@"%d/%d Words Already Used"), blackListCount, totalCount]];
	}
	 */

	[self preloadSymbolViews];
}

-(void)updateProgress
{
	[_scoreWidget setProgress:[_dispenser progress]];
}

-(void)onDispensingStarted
{
	
}

-(void)onDispensingStopped
{
	
}

-(void)onNoMorePieces
{
	state = DISPENSER_DONE;
	[UserPrefs setLevelPassed:self passed:TRUE];
	if ( [self languageWordCount] - [self validSelectedWordCount] <= 0 )
		[UserPrefs setLevelExhausted:self passed:TRUE];
	
	/*
	[self clearBoard];
	[_soundTheme dispenserDoneWarning];
	 */
	
	grace = [_board isEmpty] ? 0 : gameWonGrace;
}

-(BOOL)onWillAcceptPiece
{
	// limiting number of words?
	if ( pauseOnWordCount > 0 )
	{
		CSetWrapper*		wordSet = [_logic generateBoardWordSet:NULL forBoard:_board withWordValidator:_wordValidator withMinWordSize:minWordSize andMaxWordSize:0 andBlackList:NULL];
		int					size = wordSet.cs->size;
		
		if ( size >= pauseOnWordCount )
		{
			state = PAUSED;
			grace = gameOverGraceLeft;
			
			[_dispenser stopDispensing];
			return FALSE;
		}
	}
	
	if ( [_logic willAcceptPiece] )
		return TRUE;
	else
	{
		if ( state != BOARD_FULL )
		{						
			state = BOARD_FULL;
			if ( gameOverGrace )
				grace = gameOverGraceLeft;
			else
				grace = -1;
		}
		[_dispenser stopDispensing];
		return FALSE;
	}
	
}

static int timerTickCounter = 0;

-(void)onTimer
{
	CHK_DEALLOC;
	//NSLog(@"onTimer");
	//NSLog(@"gameLevel.onTimer: available memory: %g", [UIDevice currentDevice].availableMemory);
	
	if ( state == INIT )
		return;
	
	if ( state == SUSPENDED )
		return;
	
	if ( !enabledVerified && ![UserPrefs levelEnabled:_uuid] )
	{
		[self pauseGame];
		[_eventsTarget abortedLevel:self];
		
		return;
	}
	enabledVerified = TRUE;
	[_view fineTick];
	[_logic onFineGameTimer];
	
	if ( state == REPLAYING )
	{
		NSString*		word = [self getCurrentWord];
		
		if ( replayIndex < 0 )
		{
			replayIndex++;
		}
		else if ( replayIndex >= ([word length] + 0) && replayIndex < ([word length] + 10))
		{
			for ( id<Piece> p in _currentWordPieces )
				[p deselect];
			replayIndex++;
		}
		else if ( replayIndex >= ([word length] + 10) )
		{
			state = PAUSED;
			[self processValidWord:word showWord:FALSE];
		}
		else if ( _tickTimer )
		{
			[self onReplayTick];
		}
		return;
	}
	
	timerTickCounter++;
	
	// monitor
	{
		static NSString*	monText[] = {@".", @"..", @"...", @"....", @"....."};
				
		[self.view updateMonitor:monText[timerTickCounter % 5]];
	}
	
	if ( (timerTickCounter % 5) != 1 )
		return;
	
	// symbols left
	{
		int					left = [_dispenser piecesLeft];
		
		if ( left )
		{
			NSString*			text = [NSString stringWithFormat:@"%d", 
											[_dispenser piecesLeft]];
		
			[self.view updateSymbolsLeft:text];
		}
		else
			[self.view updateSymbolsLeft:@""];
	}
	
	
	idle++;
	[_view tick];
	[_logic onGameTimer];
	
	if ( boardFullWarnLeft < boardFullWarnBudget )
		boardFullWarnLeft++;
	
	// clear old rewards
	long		now = time(NULL);
	for ( id<Piece> p in [_board allPieces] )
	{
		NSNumber*		num = [p.props objectForKey:@"JokerRewardTime"];
		if ( num && (now - [num longValue] >= OLD_REWARD_CLEAR_SECS) )
			[p eliminate];
	}
	if ( _hintBoard )
		for ( id<Piece> p in [_hintBoard allPieces] )
		{
			NSNumber*		num = [p.props objectForKey:@"JokerRewardTime"];
			if ( num && (now - [num longValue] >= OLD_REWARD_CLEAR_SECS) )
				[p eliminate];
		}
	
	switch ( state )
	{
		case BOARD_FULL :
		{
			if ( ![_logic willAcceptPiece] ) // TODO: just to be sure - why is this needed??
			{
				if ( grace == -1 )
					break;
				[_scoreWidget setProgress2:1.0 - ((float)(grace - 1)) / gameOverGrace];
				grace--;
				
				if ( grace <= 0 )
				{
					// use wallet?
					Wallet*		wallet = [Wallet singleton];
					if ( [wallet hasSteppedWalletItem:DECORATOR_COIN] )
					{
						// saved!
						[wallet incrWalletItemValueByStep:DECORATOR_COIN incr:-1];
						[_soundTheme decoration:DECORATOR_COIN];
						[_scoreWidget updateWallet];
						grace = gameOverGraceLeft;
					}
					else
					{
						[_soundTheme failedLevel];
						state = GAME_OVER;
						[self gameOverAlert];
					}
				}
				else
				{
					if ( grace <= 10 || (grace % 2) )
					{
						if ( boardFullWarnLeft >= boardFullWarnCost )
						{
							[_soundTheme boardFullWarning];
							boardFullWarnLeft -= boardFullWarnCost;
						}
					}
				}
			}
			
			if ( f_boardFullNoHint )
			{
				f_boardFullNoHint = FALSE;
				
				[self clearBoard];

				state = PLAYING;
				gameOverGraceLeft = MAX(grace, gameOverGraceLeft);
				[_dispenser resumeDispensing];
			}
			
						
			break;
		}

		case DISPENSER_DONE :
		{
			[_scoreWidget setProgress3:1.0 - (float)grace / gameWonGrace];
			if ( (grace % 5) == 4 )
				[_soundTheme dispenserDoneWarning];			
			
			// SIG2
			if ( [self boardWordCount] == 0 )
			{
				[self clearBoard];
				grace = 0;
			}
			
			if ( grace-- <= 0 )
			{
				[_soundTheme passedLevel];
				state = GAME_WON;
				[self clearBoard];
				[self performSelector:@selector(gameWonAlert) withObject:self afterDelay:0.4];
			}

			break;
		}
	}
	
	if ( hintsEnabled && (state != GAME_WON && state != GAME_OVER) )
	{	
		// generate hint?
		if ( idle >= idleToHintGrace && !hintPending && !_hintWord )
		{
			if ( showHintWord || showHintImage || showHintPieces || speakHintWord )
			{
				hintPending = TRUE;
				manualHint = FALSE;
				
				[SystemUtils threadWithTarget:self selector:@selector(generateHintThread:) object:self];
			}
			idle = 0;
			idleToHintGrace = betweenHintDelay;
			
		}
		
		// hint?
		int				hintIndexOffset = showHintImage ? 1 : 0;
		if ( !hintPending && _piecesHint && (hintIndex < ([_piecesHint size] + hintIndexOffset)) )
		{
			// just hinted?
			if ( hintIndex == 0 )
			{
				if ( showHintPieces )
					[self resetCurrentWordPieces];

				if ( _hintWord && speakHintWord && !autorun )
				{
					if ( CHEAT_ON(CHEAT_SPEAK_LETTER_SPELLING) )
						[self speak:[self spelledWord:_hintWord]];
					else
						[self speak:_hintWord];
				}

				if ( showHintImage && !autorun )
				{
					// hint has image?
					UIImage*	hintImage = [_language wordImage:[_wordValidator wordForHintWord:_hintWord]];
					if ( hintImage )
					{
						if ( !jokerImageHints )
							[self.view showHintImage:hintImage withEnvelope:[self flashEnvelope]];
						else
						{
							// remove all pieces that are hints
							[self removeAllJokerHints:nil];
							
							// try to make sure that we have free space for this piece
							if ( !_hintBoard && ![_logic willAcceptPiece] )
							{
								NSMutableArray*		pieces = [NSMutableArray arrayWithArray:[_board allPieces]];
								NSArray*			hintPieces = [_piecesHint allPieces];
								
								[pieces shuffle];
								for ( id<Piece> piece in pieces )
									if ( ![hintPieces containsObject:piece] )
									{
										[piece eliminate];
										break;
									}
							}
							
							SymbolPiece*	piece = [[[SymbolPiece alloc] init] autorelease];
							
							piece.symbol = [JokerUtils jokerCharacter];
							piece.image = hintImage;
							[piece.props setObject:[NSNumber numberWithBool:TRUE] forKey:@"JokerHint"];
							[piece.props setObject:_hintWord forKey:@"JokerHintWord"];
							[piece.props setObject:[_wordValidator wordForHintWord:_hintWord] forKey:@"JokerHintWord1"];

							if ( _hintBoard )
								[_hintBoard placePiece:piece at:0];
							else if ( [_logic willAcceptPiece] )
								[_logic pieceDispensed:piece];
							[piece examine];
						}
					}
				}
				if ( showHintWord )
				{
					if ( CHEAT_ON(CHEAT_TEXT_HINT_MODE_1) )
					{
						NSDictionary*	metaData = [_language wordMetaData:_hintWord];
						NSString*		w = [metaData objectForKey:WMD_TEXT];
						if ( w && [w length] > 30 )
							w = [[w substringToIndex:30] stringByAppendingString:@" ..."];
						if ( !w )
							w = _hintWord;
						
						if ( CHEAT_ON(CHEAT_TEXT_HINT_MODE_2) )
							[_scoreWidget setMessage:[_wordValidator wordForHintWord:w]];
						else
						{
							[_scoreWidget setMessage1:[_wordValidator wordForHintWord:_hintWord]];
							[_scoreWidget setMessage2:[_wordValidator wordForHintWord:w]];
						}
					}
					else
						[self updateHintWord];
				}
				
				if ( autorun )
				{
					double		delayUnit = [SystemUtils autorunDelay];
					//NSLog(@"autorun: hintWord=%@", _hintWord);
					
					// use jokers (half the time ...) - only if logic has no disablers ...
					BOOL		useJokers = ![_logic includesRole:[[[[CrossPieceDisabler alloc] init] autorelease] role]];
					
					// if already contains a joker, do not use a joker
					if ( useJokers )
						for ( id<Piece> piece in [_piecesHint allPieces] )
							if ( [JokerUtils pieceIsJoker:piece] )
							{
								useJokers = FALSE;
								break;
							}
					
					if ( useJokers )
					{
						id<Piece>	jokerPiece = NULL;
						for ( id<Piece> piece in [_board allPieces] )
							if ( [JokerUtils pieceIsJoker:piece] && [self joker:piece validForWord:_hintWord] )
							{
								jokerPiece = piece;
								break;
							}
						if ( jokerPiece && rand() % 2 )
						{
							int		ofs = rand() % [_piecesHint size];
							id<Piece> oldPiece = [_piecesHint replacePieceAt:ofs withPiece:jokerPiece];
							
							NSMutableString*	s = [NSMutableString string];
							[oldPiece appendTo:s];
							//NSLog(@"replaced piece w/ joker. piece=%@", s);
						}
					}
					
					// remove all selections
					[_logic wordSelectionCanceled];
					[self resetCurrentWordPieces];
					
					// schedule clicking pieces
					// TODO: remove warnings
					for ( int n = 0 ; n < [_piecesHint size] ; n++ )
					{
						double			delay = delayUnit * (n + 1);
						id<Piece>		piece = [_piecesHint pieceAt:n];
						BOOL			last = (n == [_piecesHint size] - 1);
						[self performSelector:@selector(autorunClickPiece:) 
								withObject:[NSArray arrayWithObjects:piece, 
											[NSNumber numberWithBool:last], 
											[NSNumber numberWithFloat:!useJokers ? 0.0 : 0.5],
											_hintWord,
											[NSNumber numberWithInt:n],
											NULL] afterDelay:delay];
							
					}
				}
				
			}
			
			// hint ...
			if ( hintIndex - hintIndexOffset >= 0 )
			{
				id<Piece>		piece = [_piecesHint pieceAt:hintIndex - hintIndexOffset];
				if ( piece == NULL || [piece cell] == NULL || [[piece cell] board] != _board )
				{
					[self resetHint];
				}
				else
				{
					BOOL			last = ++hintIndex >= ([_piecesHint size] + hintIndexOffset);

					if ( showHintPieces )
					{
						[piece hinted:last];

						if ( last )
						{
							[_soundTheme pieceHintedLast];
							[self resetHint];
						}
						else
							[_soundTheme pieceHinted];
					}
					else
						[self resetHint];

					idle = 0;
					idleToHintGrace = betweenHintDelay;
				}
			}
			else
				hintIndex++;
		}
	}
	
}

-(void)autorunClickPiece:(NSArray*)args
{
	CHK_DEALLOC;
	id<Piece>		piece = [args objectAtIndex:0];
	BOOL			last = [((NSNumber*)[args objectAtIndex:1]) boolValue];
	float			forceJokerProb = [((NSNumber*)[args objectAtIndex:2]) floatValue];
	NSString*		hintWord = [args objectAtIndex:3];
	
	//NSNumber*		pieceIndex = [args objectAtIndex:4];
	//NSLog(@"autorunClickPiece: '%@', last=%d, %@, %d", [piece text], last, hintWord, [pieceIndex intValue]);
	
	// if piece is not already selected and is enabled, all is fine ...
	BOOL		forceJoker = (rand() / (float)RAND_MAX) < forceJokerProb;
	if ( !forceJoker && ![piece selected] && ![piece disabled] )
		[piece clicked];
	else
	{
		// must scan board for a piece with the same contents (or a joker ...), which is not select and is enabled
		id<Piece>			foundPiece = NULL;
		for ( id<Piece> p in [_board allPieces] )
		{
			id<Piece>	candidatePiece = NULL;
			
			if ( forceJoker || p != piece )
			{
				if ( [piece sameContentAs:p] )
					candidatePiece = p;
				else if ( [JokerUtils pieceIsJoker:p] && [self joker:p validForWord:hintWord] )
					candidatePiece = p;
				
				if ( candidatePiece && ![p selected] && ![p disabled] )
				{
					foundPiece = candidatePiece;
					break;
				}
			}
			
		}
		
		if ( foundPiece )
		{
			piece = foundPiece;
			[piece clicked];
		}
		else
			piece = NULL;
	}
				
	
	// if is last, schedule a second click
	if ( piece && last )
		[self performSelector:@selector(autorunClickPieceUnconditional:) withObject:piece afterDelay:[SystemUtils autorunDelay]];
}

-(void)autorunClickPieceUnconditional:(id<Piece>)piece
{
	CHK_DEALLOC;
	//NSLog(@"autorunClickPieceUnconditional: '%@'", [piece text]);

	[piece clicked];
}

-(void)gameWonAlert
{
	CHK_DEALLOC;
	[self updateProgress];
	[_dispenser stopDispensing];
	[_scoreWidget commitScore];
	[_logic onGameWon];
	[_scoreWidget setPlayState:PS_NONE];
	[_scoreWidget setGameAction:GA_NONE];
	
	if ( _tickTimer != NULL )
	{
		if ( [_tickTimer isValid] )
			[_tickTimer invalidate];
		
		self.tickTimer = NULL;
	}
		
	if ( ![self alertAddCandidates] )
		[self gameWonAlert_Part2];
}

-(void)gameWonAlert_Part2
{
	CHK_DEALLOC;
	if ( !showSummarySplash )
		[self gameWonAlert_Part3];
	else
	{
		self.summarySplashPanel = [[[SplashPanel alloc] init] autorelease];
		_summarySplashPanel.delegate = self;
		_summarySplashPanel.title = _title;
		
		// build text for the splash
		NSMutableString*	text = [NSMutableString string];
		
		// collect valid words for this step
		ScoresDatabase*		sdb = [ScoresDatabase singleton];
		int					score = 0;
		NSMutableArray*		validWords = [NSMutableArray array];
		BOOL				showScore = SHOW_SCORE_IN_SUMMARY_SPLASH;
		
		NSMutableArray*		sortedWords = [NSMutableArray arrayWithArray:[_selectedWords allKeys]];
		[sortedWords sortUsingSelector:@selector(compare:)];
		
		for ( NSString* word in sortedWords )
		{
			GameLevel_WordInfo*		wordInfo = [_selectedWords objectForKey:word];
			
			if (  wordInfo.type == WI_ADDED || wordInfo.type == WI_VALID )
				[[Wallet singleton] addHintBlackWord:word];
			
			if ( wordInfo )
			{
				if ( wordInfo.type == WI_ADDED || wordInfo.type == WI_VALID )
				{
					NSString*	scoredWord;
					NSString*	word2 = [_wordValidator wordForHintWord:word];
					
					if ( showScore && wordInfo.scoreContrib > 2 )
						scoredWord = [NSString stringWithFormat:@"%@ - %@%@",
												word2,
												wordInfo.scoreContribFancy ? @"*" : @"",
												[[sdb scoreNumberFormatter] stringFromNumber:[NSNumber numberWithInt:wordInfo.scoreContrib]]];
					else
						scoredWord = word2;
					
														
					[validWords addObject:scoredWord];
					score += wordInfo.scoreContrib;
				}
			}
		}
		[text appendString:[validWords componentsJoinedByString:@", "]];
		
		// score area
		int				maxScore = [sdb maxScoreForLevel:_uuid onLanguage:[_language uuid]];
		BOOL			newRecord = score > maxScore;
		if ( score )
			_summarySplashPanel.title = [NSString stringWithFormat:@"%@ : %@",
										 newRecord ? LOC(@"New Level Record") : LOC(@"Level Score"),
										 [[sdb scoreNumberFormatter] stringFromNumber:[NSNumber numberWithInt:score]]];
		else
			_summarySplashPanel.title = LOC(@"Level Passed");
		if ( newRecord )
			[_soundTheme performSelector:@selector(decorationExtra:) withObject:DECORATOR_COIN afterDelay:0.3];
		_summarySplashPanel.buttonText = LOC(@"Next Level");
		
		// assign text
		_summarySplashPanel.text = [NSString stringWithFormat:LOC(@"Words You Just Spelled:\n\n%@"), text];
		
		
		[_scoreWidget setMessage:@""];
		[_summarySplashPanel show];
	}
}

-(void)gameWonAlert_Part3
{
	CHK_DEALLOC;
	if ( _eventsTarget )
	{
		[_eventsTarget passedLevel:self withMessage:showSummarySplash ? NULL : LOC(@"Very Nice!") andContext:NULL];
	}
	else
	{
		UIAlertView*	alert = [[[UIAlertView alloc] initWithTitle:LOC(@"Very Nice!")	message:LOC(@"No More Symbols") 
													   delegate:self cancelButtonTitle:LOC(@"OK") 
											   otherButtonTitles:NULL] autorelease];
		
		[alert show];
	}
}


-(void)gameOverAlert
{
	CHK_DEALLOC;
	// game over because the board is full
	[self updateProgress];
	[_dispenser stopDispensing];
	[_scoreWidget commitScore];
	[_logic onGameOver];
	[_scoreWidget setPlayState:PS_NONE];
	[_scoreWidget setGameAction:GA_NONE];
	
	if ( _tickTimer != NULL )
	{
		if ( [_tickTimer isValid] )
			[_tickTimer invalidate];
		
		self.tickTimer = NULL;
	}
	
	if ( ![self alertAddCandidates] )
		[self gameOverAlert_Part2];
}	

-(void)gameOverAlert_Part2
{
	CHK_DEALLOC;
	if ( !showSummarySplash )
		[self gameOverAlert_Part3];
	else
	{
		int		wordLimit = 20;
		
		self.summarySplashPanel = [[[SplashPanel alloc] init] autorelease];
		_summarySplashPanel.delegate = self;
		
		// build text for the splash
		NSMutableString*	text = [NSMutableString string];
		
		// collect words on the board for this step
		NSMutableArray*		pieces;
		CSetWrapper			*wordsSet = [_logic generateBoardWordSet:&pieces forBoard:_board withWordValidator:_wordValidator withMinWordSize:minWordSize andMaxWordSize:0 andBlackList:_blackList];

		_summarySplashPanel.title = LOC(@"Level Failed!");
		NSMutableArray*		boardWords = [NSMutableArray array];
		BOOL				notAllDisplayed = FALSE;
		if ( wordsSet.cs->size <= wordLimit )
		{
			for ( int wordMemberIndex = 0 ; wordMemberIndex < wordsSet.cs->size ; wordMemberIndex++ )
				[boardWords addObject:[_language getWordByIndex:wordsSet.cs->elems[wordMemberIndex]]];
		}
		else
		{
			for ( int n = 0 ; n < (wordLimit*2) ; n++ )
			{
				int			wordMemberIndex = rand() % wordsSet.cs->size;
				NSString*	word = [_language getWordByIndex:wordsSet.cs->elems[wordMemberIndex]];
				if ( ![boardWords containsObject:word] )
					[boardWords addObject:word];
				if ( [boardWords count] >= wordLimit )
					break;
			}
			notAllDisplayed = TRUE;
		}
		[boardWords sortUsingSelector:@selector(compare:)];
		[text appendString:[boardWords componentsJoinedByString:@", "]];
		if ( notAllDisplayed )
			[text appendString:@" ..."];
		[text appendString:@"\n"];
		if ( ![_logic includesRole:@"Disable!"] )
			[text appendString:[NSString stringWithFormat:LOC(@"[%d words on board]"), wordsSet.cs->size]];
		else
			[text appendString:[NSString stringWithFormat:LOC(@"[at least %d words on board]"), wordsSet.cs->size]];
		
		// assign text
		_summarySplashPanel.text = _summarySplashPanel.text = [NSString stringWithFormat:LOC(@"Words On Board:\n\n%@"), text];
		_summarySplashPanel.buttonText = LOC(@"Try Again");
		
		[_scoreWidget setMessage:@""];
		[_summarySplashPanel show];
	}
}	

-(void)gameOverAlert_Part3
{
	CHK_DEALLOC;
	if ( _eventsTarget )
	{
		[_eventsTarget failedLevel:self withMessage:showSummarySplash ? NULL : LOC(@"Board Full!") andContext:NULL];
	}
	else
	{
		UIAlertView*	alert = [[[UIAlertView alloc] initWithTitle:LOC(@"Game Over")	message:LOC(@"Board Full") 
													   delegate:self cancelButtonTitle:LOC(@"OK") 
											   otherButtonTitles:NULL] autorelease];
		
		[alert show];
	}
}	

-(void)pauseGame
{
	CHK_DEALLOC;
	state = PAUSED;
	grace = pausedGrace;
	[_dispenser stopDispensing];	
	
	[_scoreWidget commitScore];
	/*
	if ( allowPlayPause )
		[_scoreWidget setPlayState:PS_PAUSED];
	*/
}

-(void)suspendGame
{
	CHK_DEALLOC;
	// push state
	[_stateWhenSuspended insertObject:[NSNumber numberWithInt:state] atIndex:0];

	state = SUSPENDED;
	[_dispenser stopDispensing];		
	[_scoreWidget commitScore];
	if ( allowPlayPause )
		[_scoreWidget setPlayState:PS_PAUSED];
	
	[_board setPiecesSelectable:FALSE];
}

-(void)suspendGameWithAutomaticResumeAfter:(int)seconds
{
	CHK_DEALLOC;
	if ( state != SUSPENDED && state != DISPENSER_DONE )
	{
		[self suspendGame];
		[_board setPiecesSelectable:TRUE];
		
		if ( autorun )
			seconds = 1;
		
		[self performSelector:@selector(resumeGameIfSuspended:) withObject:self afterDelay:seconds];
	}
}

-(void)resumeGameIfSuspended:(id)sender
{
	if ( state == SUSPENDED )
		[self resumeGame];
}

-(void)resumeGame
{
	CHK_DEALLOC;

	// pop state
	if ( [_stateWhenSuspended count] == 0 )
		return;
	NSNumber*		v = [_stateWhenSuspended objectAtIndex:0];
	[_stateWhenSuspended removeObjectAtIndex:0];
	state = [v intValue];
	
	if ( state != SUSPENDED )
	{
		if ( state != DISPENSER_DONE && state != PAUSED )
			[_dispenser resumeDispensing];
		
		if ( allowPlayPause )
			[_scoreWidget setPlayState:PS_PLAYING];
		
		[_board setPiecesSelectable:TRUE];
	}
	
}

-(void)stopGame
{
	CHK_DEALLOC;
	
	if ( state == INIT || state == LOADED )
	{
		state = STOPPED;
		return;
	}
	
	if ( self.helpSplashPanel )
		[self.helpSplashPanel abort];
	if ( self.textSplashPanel )
		[self.textSplashPanel abort];
	if ( self.summarySplashPanel )
	{
		[self.summarySplashPanel abort];
		self.summarySplashPanel = NULL;
	}
	
	[self pauseGame];
	state = STOPPED;
	
	if ( _tickTimer != NULL )
	{
		if ( [_tickTimer isValid] )
			[_tickTimer invalidate];
		
		self.tickTimer = NULL;
	}

	[_scoreWidget commitScore];
	[_scoreWidget setPlayState:PS_NONE];
	[_scoreWidget setGameAction:GA_NONE];
}

-(void)onPieceDispensed:(id<Piece>)piece withContext:(void*)context
{	
	CHK_DEALLOC;
	// hack ... no more possible words ...
	NSString*		originalSymbol = [piece.props objectForKey:@"OriginalSymbol"];
	if ( originalSymbol && [originalSymbol length] && [originalSymbol characterAtIndex:0] == [JokerUtils jokerCharacter] )
	{
		if ( [self boardWordCount] == 0 )
		{
			// we are done ...
			[_dispenser stopDispensing];
			[self onNoMorePieces];
			return;
		}
	}
	
	
	// hack ... hint on first symbol
	id<PieceDispensingHints>	hints = [[piece props] objectForKey:@"hints"];
	if ( hints && [hints hasHint:@"WordSymbolIndex"] )
	{
		NSString*	word = [hints stringHint:@"Word"];
		int			wordDispensingIndex = [hints intHint:@"WordDispensingIndex"];
		
		if ( !wordDispensingIndex )
		{
			[_wordValidator wordDispensed:word];

			if ( showWordImageOnDispensed )
			{
				// hint has image?
				UIImage*	hintImage = [_language wordImage:word];
				if ( hintImage )
					[self.view showHintImage:hintImage withEnvelope:[self flashEnvelope]];
			}
			if ( speakWordOnDispensed )
				[self speak:word];
		}
		
		// on hinted pieces, reset idle to prevent premature hints
		idle = 0;
		idleToHintGrace = showHintDelay;
	}
	
	
	[_logic pieceDispensed:piece];
	
	[_soundTheme pieceDispensed];
	[self updateProgress];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	exit(0);
}

-(void)pieceSelected:(id<Piece>)piece
{
	CHK_DEALLOC;
	// if this selection will exceed the max word size of the language, terminate the selected word first (or clear ...)
	if ( autoMaxWordSizeBehavior != AutoMaxWordSizeBehaviorNone )
		if ( [_currentWordPieces count] >= [_language maxWordSize] )
		{
			if ( autoMaxWordSizeBehavior == AutoMaxWordSizeBehaviorTerminate )
				[self pieceReselected:[_currentWordPieces lastObject]];
			else if ( autoMaxWordSizeBehavior == AutoMaxWordSizeBehaviorReset )
				[self resetCurrentWordPieces];
	}
	
	idle = 0;
	idleToHintGrace = betweenHintDelay;
	[self resetHint];
	
	[_logic pieceSelected:piece];
	[_soundTheme pieceSelected];
	
	// force state on user actions ...
	if ( state == PAUSED || state == HINTING )
	{
		state = PAUSED;
		grace = pausedGrace;
	}
	
	[_currentWordPieces addObject:piece];
	[self updateCurrentWord];
	
	[self updateProgress];
}

-(void)updateCurrentWord
{
	NSMutableString*		s = [[[NSMutableString alloc] init] autorelease];
	
	for ( id<Piece> p in _currentWordPieces )
		[p appendTo:s];
	
	[_scoreWidget setMessage:[_wordValidator wordForHintWord:s]];
}

-(void)pieceReselected:(id<Piece>)piece
{
	CHK_DEALLOC;
	idle = 0;
	idleToHintGrace = betweenHintDelay;
	[self resetHint];
	
	// force state on user actions ...
	if ( state == PAUSED || state == HINTING )
	{
		state = PAUSED;
		grace = pausedGrace;
	}
	
	
	// if last piece selected, verify word
	if ( [_currentWordPieces count] > 0 && (!allowReselectPartialDeselect || [_currentWordPieces lastObject] == piece) )
	{
		// build word
		NSString*	word = [self getCurrentWord];
		
		// lookup word info
		BOOL		wordTooShort = minWordSize && ([word length] < minWordSize);
		BOOL		wordContainsJoker = [JokerUtils containsJoker:word];
		NSSet*		wordJokerWords = [self getCurrentWordJokerWords];
		NSString*	wordValidatorWord = [_wordValidator isValidWord:word withBlackList:_blackList withWhiteListWords:wordJokerWords];
		BOOL		wordValidatorValid = (wordValidatorWord != NULL);
		BOOL		wordValid = wordValidatorValid && !wordTooShort;
		if ( wordValid )
		{
			word = wordValidatorWord;
			
			// must be one word joker at the most
			if ( wordContainsJoker && [wordJokerWords count] && 
					([wordJokerWords count] > 1 || ![wordJokerWords containsObject:word]) )
				wordValid = FALSE;
		}
		
		if ( !wordValid )
		{
			//NSLog(@"word invalid: word=%@", word);
			
			// special case ...
			Wallet*		wallet = [Wallet singleton];
			
			if ( [word length] == 1 && [wallet hasSteppedWalletItem:DECORATOR_BOMB] )
			{
				if ( [piece hasDecorator:DECORATOR_BOMB] )
				{
					// blow it ...
					[wallet incrWalletItemValueByStep:DECORATOR_BOMB incr:-1]; 
					wordValid = TRUE;
				}
			}
			else if ( [word length] == 3 && [wallet hasSteppedWalletItem:DECORATOR_APPLE] )
			{
				BOOL		allApplesNonJokers = TRUE;
				for ( id<Piece> p in _currentWordPieces )
					if ( ![p hasDecorator:DECORATOR_APPLE] || [JokerUtils pieceIsJoker:p] 
							|| ![p isKindOfClass:[SymbolPiece class]] )
					{
						allApplesNonJokers = FALSE;
						break;
					}
				
				if ( allApplesNonJokers )
				{
					// turn all current pieces into jokers ...
					[wallet incrWalletItemValueByStep:DECORATOR_APPLE incr:-1]; 
					[_scoreWidget updateWallet];
					for ( id<Piece> p in _currentWordPieces )
					{
						[p deselect];
						[p removeDecorator:DECORATOR_APPLE];
						[((SymbolPiece*)p) setSymbol:[JokerUtils jokerCharacter]];
					}
					[self resetCurrentWordPieces];
					[_soundTheme decorationExtra:DECORATOR_APPLE];
				}
			}
			
		}
		GameLevel_WordInfo*	wordInfo = [_selectedWords objectForKey:word];
		
		if ( wordContainsJoker && !wordValid )
			;
		else if ( !wordInfo )
		{
			wordInfo = [[[GameLevel_WordInfo alloc] init] autorelease];
			wordInfo.type = wordValid ? WI_VALID : WI_INVALID;
			wordInfo.count = 1;
			[_selectedWords setObject:wordInfo forKey:word];
		}
		else
			wordInfo.count++;

		if ( wordContainsJoker && !wordValid )
		{
			// word is a meanless joker combination!, reset selection
			[self resetCurrentWordPieces];
			[_logic invalidWordSelected:word];
			[_soundTheme wordInvalid];
			idleToHintGrace = showHintDelay;
		}
		else if ( !allowDupWords && ((wordInfo.type == WI_VALID  && wordInfo.count > 1) || (wordInfo.type == WI_BLACKLISTED)) )
		{
			// word is on the blacklist!, reset selection
			[self resetCurrentWordPieces];
			[_logic invalidWordSelected:word];
			[_soundTheme wordBlackListed];
			[_scoreWidget setMessage1:word];
			[_scoreWidget setMessage2:LOC(@"Word Already Used!")];
			idleToHintGrace = showHintDelay;
		}
		else if ( wordInfo.type == WI_VALID || wordInfo.type == WI_ADDED )
		{
			[_logic validWordSelected:word];
			[_wordValidator wordCompleted:word];
			[_soundTheme wordValid:speakRewardWord ? word : NULL fromLanguage:_language];
			
			// replay valid word?
			if ( replayValidWord )
			{
				// deselect all word pieces
				for ( id<Piece> p in _currentWordPieces )
					[p deselect];
				replayIndex = -5;
				
				// start replay
				state = REPLAYING;
				[self onReplayTick];
			}
			else
			{
				// add to score
				if ( !autorun || autorunAccumulateScore )
				{
					int			count = [self currentWordPiecesNonJokerCount];
					float		score = count ? pow(2, count) : 0;
					int			finalScore = [_logic scoreSuggested:score forPieces:_currentWordPieces];

					if ( score != finalScore )
						wordInfo.scoreContribFancy = TRUE;
					finalScore *= scoreFactor;
					wordInfo.scoreContrib = wordInfo.scoreContrib + finalScore;
					
					validWordCount++;
					[_scoreWidget addToScore:finalScore];
				}
				
				// process as valid
				[self processValidWord:word showWord:wordContainsJoker];
				idleToHintGrace = showHintDelay;
			}
		}
		else if ( wordInfo.type == WI_INVALID )
		{
			if ( wordTooShort )
			{
				[self resetCurrentWordPieces];
				[_logic invalidWordSelected:word];
				[_soundTheme wordInvalid];
				[_scoreWidget setMessage1:word];
				[_scoreWidget setMessage2:LOC(@"Word Too Short!")];
				idleToHintGrace = showHintDelay;
			}
			// alert on second count
			else if ( allowAddWords && askToAddWords_Global && askToAddWords_Level && wordInfo.count == 2 )
			{
				[self suspendGame];
				[self alertInvalidWordCandidate:word withInfo:wordInfo];
			}
			else
			{
				// word invalid!, reset selection
				[self resetCurrentWordPieces];
				[_logic invalidWordSelected:word];
				[_soundTheme wordInvalid];
				idleToHintGrace = showHintDelay;
			}
		}
	}
	else
	{
		// not last, reset all pieces from reselected piece and to end
		int			index = [_currentWordPieces indexOfObject:piece];
		if ( index != NSNotFound )
		{
			while ( [_currentWordPieces count] > index )
			{
				id<Piece>	p = [_currentWordPieces lastObject];
				[_currentWordPieces removeLastObject];
				
				[p reset];
			}
		}
		[self updateCurrentWord];
		[_logic wordSelectionCanceled];
		[_soundTheme wordReset];
	}
	
}

-(void)processValidWord:(NSString*)word showWord:(BOOL)showWord
{
	CHK_DEALLOC;
	BOOL		removedJokerWord = FALSE;
	
	// only for the first word ...
	showHintPieces = FALSE;
	
	// success!, eliminate selection
	if ( jokerImageHints )
		removedJokerWord = [self removeAllJokerHints:word];
	for ( id<Piece> p in [_logic eliminationSuggested:_currentWordPieces] )
		[p eliminate];
	[_currentWordPieces removeAllObjects];
	
	// wipe?
	if ( autoValidWordWipe )
	{
		// wipe out the board
		[self clearBoard];
	}	
	
	// add to blackList
	if ( !allowDupWords )
	{
		int		index = [_language wordIndex:word];
		if ( index >= 0 && !CSet_IsMember(_blackList.cs, index) )
		{
			CSet_AddElement(_blackList.cs, index);
			CSet_SortElements(_blackList.cs);
		}
		if ( index >= 0 && !CSet_IsMember(_hintBlackList.cs, index) )
		{
			CSet_AddElement(_hintBlackList.cs, index);
			CSet_SortElements(_hintBlackList.cs);
		}
	}
	
	BOOL	boardWasEmpty = [_board isEmpty];
	
	NSDictionary*	wordMetaData = [_language wordMetaData:word];
	
	// show reward image?
	if ( showWordImageOnValid && showRewardImage )
	{
		// reward has image?
		UIImage*	hintImage = [wordMetaData objectForKey:WMD_IMAGE];
		if ( hintImage )
		{
			if ( !jokerImageRewards )
				[self.view showHintImage:hintImage withEnvelope:[self flashEnvelope]];
			else if ( !removedJokerWord )
			{
				SymbolPiece*	piece = [[[SymbolPiece alloc] init] autorelease];
				
				piece.symbol = [JokerUtils jokerCharacter];
				piece.image = hintImage;
				[piece.props setObject:[NSNumber numberWithBool:TRUE] forKey:@"JokerHint"];
				[piece.props setObject:word forKey:@"JokerHintWord"];
				[piece.props setObject:[_wordValidator wordForHintWord:word] forKey:@"JokerHintWord1"];
				[piece.props setObject:[NSNumber numberWithLong:time(NULL)] forKey:@"JokerRewardTime"];

				if ( _hintBoard )
					[_hintBoard placePiece:piece at:0];
				else if ( [_logic willAcceptPiece] )					
					[_logic pieceDispensed:piece];
				
				[piece examine];
			}
		}
	}
	
	// show reward word?
	if ( showWord )
		[self.scoreWidget setMessage:word];
	
	if ( showRewardText )
	{
		if ( [wordMetaData objectForKey:WMD_TEXT] )
		{
			if ( CHEAT_ON(CHEAT_TEXT_HINT_MODE_1) )
			{
				NSString*		w = [wordMetaData objectForKey:WMD_TEXT];
				if ( [w length] > 30 )
					w = [[w substringToIndex:30] stringByAppendingString:@" ..."];
				
				[_scoreWidget setMessage1:[_wordValidator wordForHintWord:word]];
				[_scoreWidget setMessage2:[_wordValidator wordForHintWord:w]];
			}
			else
			{
				self.textSplashPanel = [[[SplashPanel alloc] init] autorelease];
				
				_textSplashPanel.title = [wordMetaData objectForKey:WMD_TEXT_TITLE] ? [wordMetaData objectForKey:WMD_TEXT_TITLE] : word;
				_textSplashPanel.text  = [wordMetaData objectForKey:WMD_TEXT];
				if ( [wordMetaData objectForKey:WMD_IMAGE] )
					_textSplashPanel.icon = [wordMetaData objectForKey:WMD_IMAGE];
				_textSplashPanel.delegate = self;
				
				NSDictionary*		props = [wordMetaData objectForKey:WMD_PROPS];
				if ( [props hasKey:WMD_PROPS_SPLASH_TEXT_FONT_SIZE] )
					_textSplashPanel.textFontSize = [props floatForKey:WMD_PROPS_SPLASH_TEXT_FONT_SIZE withDefaultValue:14.0];
				
				[_textSplashPanel performSelector:@selector(show) withObject:self afterDelay:0.1];
			}
		}
	}
	
	// board was paused?
	if ( state == PAUSED && pauseOnWordCount > 0 )
	{
		pauseOnWordCount += pauseOnWordCountIncrement;
		
		// back to playing
		state = PLAYING;
		gameOverGraceLeft = MAX(grace, gameOverGraceLeft);
		[_dispenser resumeDispensing];
		if ( allowPlayPause )
			[_scoreWidget setPlayState:PS_PLAYING];
	}
	// board was full?
	if ( state == BOARD_FULL )
	{
		// back to playing
		state = PLAYING;
		gameOverGraceLeft = MAX(grace, gameOverGraceLeft);
		[_dispenser resumeDispensing];
	}
	else if ( state == DISPENSER_DONE )
	{
		// board empty?
		if ( boardWasEmpty )
		{
			state = GAME_WON;
			[self clearBoard];
			[_soundTheme passedLevel];
			[self performSelector:@selector(gameWonAlert) withObject:self afterDelay:0.4];
		}
	}
	else if ( state == PAUSED )
	{
		// board empty?
		if ( boardWasEmpty || [[_board allPieces] count] <= 1 )
		{
			for ( id<Piece> p in [_board allPieces] )
				if ( TRUE || ![JokerUtils pieceIsJoker:p] )
					[p eliminate];
			
			state = PLAYING;
			[_dispenser resumeDispensing];
			if ( allowPlayPause )
				[_scoreWidget setPlayState:PS_PLAYING];
		}
		
	}
	
	gameOverGraceLeft += ([word length] * 3);
	if ( gameOverGraceLeft > gameOverGrace )
		gameOverGraceLeft = gameOverGrace;
	
	
}

-(NSString*)getCurrentWord
{
	NSMutableString*	word = [[[NSMutableString alloc] init] autorelease];
	
	for ( id<Piece> p in _currentWordPieces )
		[p appendTo:word];

	return word;
}

-(NSSet*)getCurrentWordJokerWords
{
	NSMutableSet*		words = [NSMutableSet set];
	NSString*			word;
	
	for ( id<Piece> p in _currentWordPieces )
	{
		word = [p.props objectForKey:@"JokerHintWord"];
		if ( word )
			[words addObject:word];
		word = [p.props objectForKey:@"JokerHintWord1"];
		if ( word )
			[words addObject:word];
	}
	
	return words;
}

-(BOOL)joker:(id<Piece>)p validForWord:(NSString*)w
{
	NSString*	word;
	
	word = [p.props objectForKey:@"JokerHintWord"];
	if ( word && ![word isEqualToString:w] )
		return FALSE;

	word = [p.props objectForKey:@"JokerHintWord1"];
	if ( word && ![word isEqualToString:w] )
		return FALSE;
	
	return TRUE;
	
}

-(int)getCurrentScore
{
	return [_scoreWidget score];
}

-(void)resetCurrentWordPieces
{
	for ( id<Piece> p in _currentWordPieces )
		[p reset];
	[_currentWordPieces removeAllObjects];
	[self updateCurrentWord];
}

-(void)generateHintThread:(id)sender
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	
#ifdef DUMP_THREAD
	NSLog(@"[GameLevel-%p] generateHintThread - starts", self);
#endif	
	// TODO: remove ... this is a check (looking for a bug here)
	if ( state == INIT || !_wordValidator )
	{
		NSLog(@"TRAP: generateHintThread called when state in improper");
#ifdef _GLIBCXX_DEBUG
		@throw [NSException exceptionWithName:@"TRAP: generateHintThread called when state in improper" reason:NULL userInfo:NULL];
#else
		[pool release];
		return;
#endif
	}
	
	[self generateHint:sender];
	hintPending = FALSE;
	
#ifdef DUMP_THREAD
	NSLog(@"[GameLevel-%p] generateHintThread - finishes", self);
#endif
	[pool release];
}

-(void)generateHint:(id)sender
{
	CHK_DEALLOC;
#ifdef MEASURE
	// HACK!!
	startedAt = clock();
#endif
	
	BOOL				hintGenerated = FALSE;
	BOOL				usedMaxLimit = hintMaxWordSize != 0;
	
	// get words set
	NSMutableArray*		pieces;
	CSetWrapper			*wordsSet = [_logic generateBoardWordSet:&pieces forBoard:_board withWordValidator:_wordValidator withMinWordSize:minWordSize andMaxWordSize:hintMaxWordSize andBlackList:_hintBlackList];
	if ( (!wordsSet || !wordsSet.cs->size) && hintMaxWordSize )
	{
		wordsSet = [_logic generateBoardWordSet:&pieces forBoard:_board withWordValidator:_wordValidator withMinWordSize:minWordSize andMaxWordSize:0 andBlackList:_blackList];
		usedMaxLimit = FALSE;
	}
#ifdef	MEASURE
	NSLog(@"[GameLevel] %f generateHint after generateBoardWordSet", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif		
	if ( wordsSet )
	{
		hintWordCount = wordsSet.cs->size;
		hintWordCountAtleast = usedMaxLimit || [_logic includesRole:@"Disable!"];
		
		// update message
		//[view updateMessageArea:[[NSString alloc] initWithFormat:@"%d Valid Words", wordsSet.cs->size]];
		
		// generate a hint?
		BOOL		generateHints = TRUE;
		if ( generateHints )
		{
			[self resetHint];
			if ( wordsSet.cs->size )
			{
				hintGenerated = TRUE;
				
				int				wordIndex = wordsSet.cs->elems[rand() % wordsSet.cs->size];
				
				// if this index is the same as the last generated index, make some effort to generate another hint
				if ( wordsSet.cs->size > 1 && wordIndex == lastGeneratedHintWordIndex )
					for ( int n = 0 ; n < 5 && wordIndex == lastGeneratedHintWordIndex ; n++ )
						wordIndex = wordsSet.cs->elems[rand() % wordsSet.cs->size];
				lastGeneratedHintWordIndex = wordIndex;
				
				self.hintWord = [_wordValidator getValidWordByIndex:wordIndex];
				
				NSMutableArray*	hintPieces = [[[NSMutableArray alloc] init] autorelease];
				
				int				startingCharIndex = 0;
				id<Piece>		firstPiece = [pieces objectAtIndex:0];
				if ( [[firstPiece text] isEqualToString:[_hintWord substringToIndex:1]] )
				{
					// lucky for us ... 
					[hintPieces addObject:firstPiece];
					startingCharIndex = 1;
				}
				else
					firstPiece = NULL;
				
				for ( int charIndex = startingCharIndex ; charIndex < [_hintWord length] ; charIndex++ )
				{
					// search pieces for a matching symbol. start at a random location
					int					piecesNum = [pieces count];
					if ( !piecesNum )
					{
						[self resetHint];
						break;
					}
					int					ofs = rand() % piecesNum;
					id<Piece>			hintPiece = NULL;
					NSMutableString*	symbols = [[[NSMutableString alloc] init] autorelease];
					for ( int n = 0 ; n < piecesNum ; n++ )
					{
						id<Piece>	piece = [pieces objectAtIndex:(n + ofs) % piecesNum];
						if ( piece == NULL || piece == firstPiece )
							continue;
						NSRange		all = {0,[symbols length]};
						[symbols deleteCharactersInRange:all];
						
						NSString*	originalSymbol = [piece.props objectForKey:@"OriginalSymbol"];
						if ( originalSymbol )
							[symbols appendString:originalSymbol];
						else
							[piece appendTo:symbols];
						if ( [symbols length] && [symbols characterAtIndex:0] == [_hintWord characterAtIndex:charIndex] )
						{
							hintPiece = piece;
							[pieces removeObjectAtIndex:(n + ofs) % piecesNum];
							break;
						}
					}
					if ( hintPiece != NULL )
						[hintPieces addObject:hintPiece];
					else
					{
						[self resetHint];
						break;
					}
				}
			
				// has found a hint?
				if ( hintPieces && [hintPieces count] )
				{
					self.piecesHint = [[[ArrayPiecesHint alloc] initWithPieces:hintPieces] autorelease];
					//NSLog(@"found hint: %@", _hintWord);
				}
			}
		}
	}
	
	if ( !hintGenerated )
		[_scoreWidget performSelectorOnMainThread:@selector(setMessage:) withObject:@"" waitUntilDone:FALSE];
	else if ( showHintWord && manualHint )
		[self performSelectorOnMainThread:@selector(updateHintWord) withObject:self waitUntilDone:FALSE];
	
	if ( !hintGenerated && state == BOARD_FULL )
		f_boardFullNoHint = TRUE;
	
	idleToHintGrace = hintGenerated ? betweenHintDelay : showHintDelay;
	
#ifdef	MEASURE
	NSLog(@"[GameLevel] %f generateHint returning", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
}

-(void)resetHint
{
	hintIndex = 0;
	self.piecesHint = NULL;
	self.hintWord = NULL;
}

-(int)score
{
	return [_scoreWidget score];
}

/*
-(void)setScore:(int)score
{
	[_scoreWidget setScore:score];
}
 */

-(float)targetFullness
{
	return 1.0 - (float)[_board freeCellCount] / [_board cellCount];
}

-(float)targetProgress
{
	return MIN(1.0, validWordCount / 10.0);
}

-(void)onReplayTick
{
	if ( replayIndex < [_currentWordPieces count] )
	{
		id<Piece>	piece = [_currentWordPieces objectAtIndex:replayIndex];
		id<Piece>	piecePrev = (replayIndex >= 1) ? [_currentWordPieces objectAtIndex:(replayIndex - 1)] : 0;
		
		if ( piecePrev )
			[piecePrev deselect];
		if ( piece )
			[piece select];
	}
	
	replayIndex++;
}

-(void)onScoreWidgetTouched:(int)tapCount
{
	CHK_DEALLOC;
	switch ( tapCount )
	{
		case 1 :
			// reset
			[_soundTheme wordReset];
			[self resetHint];
			[self resetCurrentWordPieces];
			[_logic wordSelectionCanceled];
			break;
			
		case 2 :
		case 22 :
			if ( state == PAUSED || state == SUSPENDED )
			{
				
			}
			else
			{
				fullHint = tapCount == 22;
				// hint
				if ( !hintPending )
				{
					hintPending = TRUE;
					
					if ( showHintWordCount )
					{
						[_scoreWidget setMessage1:@"..."];
						[_scoreWidget setMessage2:@""];
					}
					else
						[_scoreWidget setMessage:@"..."];
					manualHint = TRUE;
					[SystemUtils threadWithTarget:self selector:@selector(generateHintThread:) object:self];
				}
			}
			break;
			
		case 3 :
			// suspend/resume
			if ( state != SUSPENDED )
			{
				[self suspendGame];
				[_view updatePauseCurtain];
				[_scoreWidget setMessage:LOC(@"paused")];
			}
			else
			{
				[self resumeGame];
				[_view updatePauseCurtain];
				[_scoreWidget setMessage:@""];
			}
			break;
			
	}
		
}

-(void)alertInvalidWordCandidate:(NSString*)word withInfo:(GameLevel_WordInfo*)wordInfo
{
	CHK_DEALLOC;
	self.addWordCandidate = word;
	
	// open a dialog with two custom buttons
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
									delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
									otherButtonTitles:[NSString stringWithFormat:LOC(@"Add '%@'"), RTL(word)], LOC(@"Not In This Level"), LOC(@"Disable Adding Words"), LOC(@"Cancel"), nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 3;	
	[actionSheet showInView:[self view]];
	[actionSheet autorelease];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	CHK_DEALLOC;
	if ( _addWordCandidate )
	{
		if ( buttonIndex == 0 )
		{
			GameLevel_WordInfo*	wordInfo = [_selectedWords objectForKey:_addWordCandidate];

			if ( wordInfo )
			{
				wordInfo.type = WI_ADDED;

				[_logic validWordSelected:_addWordCandidate];
				[_wordValidator wordCompleted:_addWordCandidate];
				[_soundTheme wordValid:_addWordCandidate fromLanguage:_language];
				
				// add tp score
				if ( !autorun || autorunAccumulateScore )
				{
					int			count = [self currentWordPiecesNonJokerCount];
					float		score = count ? pow(2, count) : 0;
					int			finalScore = [_logic scoreSuggested:score forPieces:_currentWordPieces];

					if ( finalScore != score )
						wordInfo.scoreContrib = TRUE;
					finalScore *= scoreFactor;
					wordInfo.scoreContrib = wordInfo.scoreContrib + finalScore;
					
					[_scoreWidget addToScore:finalScore];
				}
				validWordCount++;
					
				// process as valid
				[self processValidWord:_addWordCandidate showWord:FALSE];
			}
		}
		else
		{
			// in all these cases, the word remains invalid
			if ( buttonIndex == 1 )
			{
				// don't ask again
				askToAddWords_Level = FALSE;
			}
			else if ( buttonIndex == 2 )
			{
				// never ask again
				askToAddWords_Global = FALSE;
			}
			
			// word invalid!, reset selection
			[self resetCurrentWordPieces];
			[_logic invalidWordSelected:_addWordCandidate];
			[_soundTheme wordInvalid];
		}
		
		[self resumeGame];
	}
	else if ( !_commitWordCandidate )
	{
		if ( buttonIndex == 0 )
		{
			// add words
			for ( NSString* word in _commitWords )
				[_language addWord:word];
			[LanguageManager clearLanguagesCacheOf:_language];
			[_seq invalidateLanguage];
		}
		else if ( buttonIndex == 1 )
		{
			// approve one by one
			[self alertApproveWord];
			return;
		}
		
		if ( state == GAME_WON )
			[self gameWonAlert_Part2];
		else if ( state == GAME_OVER )
			[self gameOverAlert_Part2];
	}
	else if ( _commitWordCandidate )
	{
		if ( buttonIndex == 0 )
		{
			// add word
			[_language addWord:_commitWordCandidate];
			[LanguageManager clearLanguagesCacheOf:_language];
			[_seq invalidateLanguage];
		}
		
		if ( [_commitWords count] )
		{
			[self alertApproveWord];
			return;
		}
		
		if ( state == GAME_WON )
			[self gameWonAlert_Part2];
		else if ( state == GAME_OVER )
			[self gameOverAlert_Part2];
	}
}

-(BOOL)alertApproveWord
{
	CHK_DEALLOC_FALSE;
	// open a dialog with two custom buttons
	self.addWordCandidate = NULL;
	self.commitWordCandidate = [_commitWords objectAtIndex:0];
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
															  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													 otherButtonTitles:
								   [NSString stringWithFormat:LOC(@"Add '%@'"), RTL(_commitWordCandidate)],
								   LOC(@"No"), 
								   nil] 
								  autorelease];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 1;	
	[actionSheet showInView:[self view]];
	
	[_commitWords removeObjectAtIndex:0];
	
	return TRUE;
}

-(BOOL)alertAddCandidates
{
	// collect newly added words
	self.commitWords = [[[NSMutableArray alloc] init] autorelease];
	for ( NSString* word in [_selectedWords allKeys] )
	{
		GameLevel_WordInfo*		wordInfo = [_selectedWords objectForKey:word];
		
		if ( wordInfo )
		{
			if ( wordInfo.type == WI_ADDED )
				[_commitWords addObject:word];
		}
	}
	int		addedCount = [_commitWords count];

	// nothing added?
	if ( !addedCount )
		return FALSE;
	
	// open a dialog with two custom buttons
	self.addWordCandidate = NULL;
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:RTL([_commitWords componentsJoinedByString:@","])
									delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													 otherButtonTitles:
														[NSString stringWithFormat:LOC(@"Commit %d New Words"), addedCount], 
														LOC(@"Approve One By One"), 
														LOC(@"Cancel"), 
														nil] 
								  autorelease];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 2;	
	[actionSheet showInView:[self view]];

	return TRUE;
	
}

-(void)pieceClicked:(id<Piece>)piece
{
}

-(EnvelopeDynamics*)flashEnvelope
{
	EnvelopeDynamics*		envelope = [[[EnvelopeDynamics alloc] init] autorelease];
	
	envelope->points[EnvelopeDynamicsPointTypeAttack].duration = flashAttackDuration;
	envelope->points[EnvelopeDynamicsPointTypeAttack].alpha = flashAttackAlpha;
	
	envelope->points[EnvelopeDynamicsPointTypeSustain].duration = flashSustainDuration;
	envelope->points[EnvelopeDynamicsPointTypeSustain].alpha = flashSustainAlpha;
	
	envelope->points[EnvelopeDynamicsPointTypeDecay].duration = flashDecayDuration;
	envelope->points[EnvelopeDynamicsPointTypeDecay].alpha = flashDecayAlpha;
	
	return envelope;
}

-(NSMutableString*)buildRushSymbolsForDispenser
{
	// no rush
	if ( !_rushSymbols && !rushWords )
		return NULL;
	
	NSMutableString*	symbols = [[[NSMutableString alloc] init] autorelease];
	
	if ( _rushSymbols )
		[symbols appendString:_rushSymbols];

	if ( rushWords )
	{
		int				minSize = MAX(rushMinWordSize, minWordSize);
		int				maxSize = rushMaxWordSize >= minSize ? rushMaxWordSize : minSize + 2;
		CSetWrapper*	blackList = [[[CSetWrapper alloc] init] autorelease];
		CSet_Copy(_blackList.cs, blackList.cs);

		for ( int i = 0 ; i < rushWords ; i++ )
		{
			NSString*		word = [_language getRandomWord:minSize withMaxSize:maxSize withBlackList:blackList];
			if ( !word )
				break;
			
			int				wordIndex = [_language wordIndex:word];
			CSet_AddElement(blackList.cs, wordIndex);
			
			[symbols appendString:word];
			//NSLog(@"Generated rush: %@", word);
		}
	}
	
	
	return symbols;
}

-(void)splashDidShow:(SplashPanel*)panel
{
	CHK_DEALLOC;
	if ( panel == _helpSplashPanel && state != START_SPLASH )
		[self suspendGame];
	if ( panel == _textSplashPanel )
		[self suspendGame];
}

-(void)splashDidFinish:(SplashPanel*)panel
{
	CHK_DEALLOC;
	// summary?
	if ( panel == _summarySplashPanel )
	{
		self.summarySplashPanel = NULL;
		
		if ( state == GAME_OVER )
			[self gameOverAlert_Part3];
		else
			[self gameWonAlert_Part3];
		
		return;
	}
	
	// now really start the game
	if ( state == START_SPLASH )
		[self startGame];
	else
		[self resumeGame];
}

-(void)speak:(NSString*)word
{
	NSURL*		url = [_language wordSoundUrl:word];
	
	if ( url )
		[TextSpeaker play:url];
	else
	{
		NSString*	vl = [_language voiceLanguage];
		if ( !vl )
			vl = TEXTSPEAKER_VOICE_DEFAULT_LANG;
		
		[TextSpeaker speak:[NSArray arrayWithObjects: [_wordValidator wordForHintWord:word], vl, NULL]];
	}
}

-(int)currentWordPiecesNonJokerCount
{
	int		count = 0;
	
	for ( id<Piece> piece in _currentWordPieces )
		if ( ![JokerUtils pieceIsJoker:piece] )
			count++;
	
	return count;
}

-(id<Language>)targetLanguage
{
	return _language;
}

-(BOOL)removeAllJokerHints:(NSString*)word
{
	BOOL				eliminatedWord = FALSE;
	NSMutableArray*		queue = [NSMutableArray array];
	NSMutableArray*		pieces = [NSMutableArray arrayWithArray:[_board allPieces]];
	if ( _hintBoard )
		[pieces addObjectsFromArray:[_hintBoard allPieces]];
	
	for ( id<Piece> piece in pieces )
		if ( [piece.props objectForKey:@"JokerHint"] )
		{
			if ( word )
			{
				if ( [word isEqualToString:[piece.props objectForKey:@"JokerHintWord"]] )
					eliminatedWord = TRUE;
				else if ( [[_wordValidator wordForHintWord:word] isEqualToString:[piece.props objectForKey:@"JokerHintWord1"]] )
					eliminatedWord = TRUE;
			}
			
			[queue addObject:piece];
		}
	
	//NSLog(@"queue %@", queue);
	for ( id<Piece> piece in queue )
		[piece eliminate];
	
	return eliminatedWord;
}

-(int)validSelectedWordCount
{
	return [[self validSelectedWords] count];
}

-(NSSet*)validSelectedWords
{
	NSMutableSet*		words = [NSMutableSet set];
	
	for ( NSString* word in [_selectedWords allKeys] )
	{
		GameLevel_WordInfo*		wordInfo = [_selectedWords objectForKey:word];
		
		if ( wordInfo )
		{
			if ( wordInfo.type == WI_ADDED || wordInfo.type == WI_VALID || wordInfo.type == WI_BLACKLISTED )
			{
#ifdef DUMP_VALID_SELECTED_WORDS
				NSLog(@"validSelectedWords: %@", word);
#endif
				[words addObject:word];
			}
		}
	}
	
	return words;
}


-(int)languageWordCount
{
	if ( !minWordSize )
		return [_language wordCount];
	else
		return [_language getWordCount:minWordSize withMaxSize:0];
}

-(int)boardWordCount
{
	int		count = boardWordCountResult;
	
	if ( boardWordCountResult == -1 )
	{
		boardWordCountResult = -2;
		
		[SystemUtils threadWithTarget:self selector:@selector(boardWordCountThread:) object:self];
	}
	else if ( boardWordCountResult >= 0 )
		boardWordCountResult = -1;
	
	return count;
}

-(void)boardWordCountThread:(id)sender
{
	NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableArray*		pieces;
	CSetWrapper			*wordsSet = [_logic generateBoardWordSet:&pieces forBoard:_board withWordValidator:_wordValidator withMinWordSize:minWordSize andMaxWordSize:0 andBlackList:_blackList];

	boardWordCountResult = wordsSet.cs->size;
	
	[pool release];
}

-(void)clearBoard
{
	for ( id<Piece> piece in [_board allPieces] )
		[piece eliminate];
}

-(NSString*)spelledWord:(NSString*)word
{
	NSMutableString*		newWord = [NSMutableString string];
	
	[newWord appendString:word];
	[newWord appendString:@", "];
	for ( int n = 0 ; n < [word length] ; n++ )
	{
		NSString*	w = [word substringWithRange:NSMakeRange(n, 1)];
		[newWord appendString:w];
		[newWord appendString:@". "];
	}
	[newWord appendString:@". "];
	[newWord appendString:word];
	
	return newWord;
}

-(void)shaken
{
	if ( [_scoreWidget gameAction] == GA_HINT )
		[_scoreWidget pressPlayAction];
}

-(void)updateHintWord
{
	if ( !showHintWordCount )
		[_scoreWidget setMessage:[_wordValidator wordForHintWord:_hintWord]];
	else
	{
		[_scoreWidget setMessage1:[_wordValidator wordForHintWord:_hintWord]];
		if ( !hintWordCountAtleast )
			[_scoreWidget setMessage2:[NSString stringWithFormat:LOC(@"%d words on board"), hintWordCount]];
		else
			[_scoreWidget setMessage2:[NSString stringWithFormat:LOC(@"at least %d words on board"), hintWordCount]];
	}	
}

-(void)preloadSymbolViews
{
	[SymbolPieceView guardImageDictSize:FALSE];
	
	if ( [_dispenser isKindOfClass:[GridBoardPieceDispenserSymbols class]] && 
		[((GridBoardPieceDispenserSymbols*)_dispenser) dispensingTickPeriod] <= 0.1 )
	{
		fastGame = TRUE;
		
		
		GridBoardPieceDispenserSymbols*	sd = (GridBoardPieceDispenserSymbols*)_dispenser;
		id<Alphabet>	alphabet = [_language alphabet];
		int				alphabetSize = [alphabet size];
		Cell*			cell = [[_board allCells] objectAtIndex:0];
		CGRect			rect = cell.view.frame;
		Cell*			cell1 = [[[sd ownBoard] allCells] objectAtIndex:0];
		CGRect			rect1 = cell1.view.frame;
		rect.origin.x = 0;
		rect.origin.y = 0;
		for ( int n = 0 ; n <= alphabetSize ; n++ )
		{
			unichar			ch = (n < alphabetSize) ? [alphabet symbolAt:n] : [JokerUtils jokerCharacter];
			
			SymbolPiece*	p = [[[SymbolPiece alloc] init] autorelease];
			p.symbol = ch;
			SymbolPieceView*	view = (SymbolPieceView*)[p viewWithFrame:rect];
			[view buildContentView:FALSE];
			
			SymbolPiece*	p1 = [[[SymbolPiece alloc] init] autorelease];
			p1.symbol = ch;
			SymbolPieceView*	view1 = (SymbolPieceView*)[p1 viewWithFrame:rect1];
			[view1 buildContentView:FALSE];
			
		}
	}	
}

-(int)remainingCount
{
	int			blackListCount = _blackList.cs->size;
	int			totalCount = [_language getWordCount:minWordSize withMaxSize:0];

	return totalCount - blackListCount;
}

-(void)addWord:(NSString*)word toBlackList:(BOOL)addToBlackList andHintBlackList:(BOOL)addToHintBlackList
{
	int		index = [_language wordIndex:word];
	if ( index >= 0 )
	{
		if ( addToBlackList )
			CSet_AddElement(_blackList.cs, index);
		if ( addToHintBlackList )
			CSet_AddElement(_hintBlackList.cs, index);
	}
	
	if ( addToBlackList )
	{
		GameLevel_WordInfo*		wordInfo = [[[GameLevel_WordInfo alloc] init] autorelease];
		wordInfo.type = WI_BLACKLISTED;
		wordInfo.count = 1;
		[_selectedWords setObject:wordInfo forKey:word];	
	}
}

-(void)showHelpSplash
{
	if ( [_helpSplashPanel.text rangeOfString:@"[%remaining]"].length >= 0 )
	{
		NSString*	orgText = _helpSplashPanel.text;
		_helpSplashPanel.text = [orgText stringByReplacingOccurrencesOfString:@"[%remaining]" 
																   withString:[[NSNumber numberWithInt:[self remainingCount]] stringValue]];
		[_helpSplashPanel show];
		_helpSplashPanel.text = orgText;
	}
	else
		[self.helpSplashPanel show];	
}

@end
