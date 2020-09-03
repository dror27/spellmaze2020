//
//  GameLevel.h
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HasView.h"
#import	"Board.h"
#import "Language.h"
#import "SymbolDispenser.h"
#import "PieceDispenser.h"
#import "PieceDispensingTarget.h"
#import "GameLevelEventsTarget.h"
#import "PieceEventsTarget.h"
#import "SoundTheme.h"
#import "PiecesHint.h"

#import	"GameLevelView.h"
#import "GameBoardLogic.h"

#import "ScoreWidget.h"
#import "WordValidator.h"

#import "ScoreWidgetEventsTarget.h"
#import "CSetWrapper.h"

#import "SplashPanel.h"

@class Piece;

typedef enum {
	INIT,
	LOADED,
	START_SPLASH,
	PLAYING,
	PAUSED,
	HINTING,
	REPLAYING,
	BOARD_FULL,
	DISPENSER_DONE,
	GAME_OVER,
	GAME_WON,
	STOPPED,
	SUSPENDED,
	DEALLOCATED1,
	DEALLOCATED2,
	DEALLOCATED3
} GameLevelState;

typedef enum
{
	AutoMaxWordSizeBehaviorNone = 0,
	AutoMaxWordSizeBehaviorReset = 1,
	AutoMaxWordSizeBehaviorTerminate = 2
} AutoMaxWordSizeBehaviorType;

@class GameLevelSequence;
@interface GameLevel : NSObject<HasView,PieceDispensingTarget,PieceEventsTarget, ScoreWidgetEventsTarget,SplashPanelDelegate> {
	
	BOOL					loadDefaultLanguage;
	BOOL					loadDefaultBoard;
	BOOL					loadDefaultDispenser;
	BOOL					loadDefaultLogic;
										
										
	id<Board>				_board;
	id<PieceDispenser>		_dispenser;
	
	id<Language>			_language;
	id<WordValidator>		_wordValidator;

	NSMutableArray*			_currentWordPieces;
	
	ScoreWidget*			_scoreWidget;
	
	int						gameOverGrace;
	int						gameWonGrace;
	int						pausedGrace;
	int						idleToHintGrace;
	
	int						grace;
	int						idle;
	
	BOOL					hintsEnabled;
	
	NSTimer*				_tickTimer;

	GameLevelState			state;
	NSMutableArray*			_stateWhenSuspended;
	
	GameLevelView*			_view;	
	
	int						hintIndex;
	id<PiecesHint>			_piecesHint;
	NSString*				_hintWord;
	
	id<GameLevelEventsTarget> _eventsTarget;
	
	SoundTheme*				_soundTheme;
	
	id<GameBoardLogic>		_logic;
	
	int						gameOverGraceLeft;
	
	NSString*				_title;
	NSString*				_shortDescription;
	
	int						minWordSize;
	
	
	NSMutableDictionary*	_selectedWords;	
	
	NSString*				_uuid;
	BOOL					enabledVerified;
	
	BOOL					showWordImageOnDispensed;
	BOOL					showWordImageOnValid;
	BOOL					speakWordOnDispensed;
	
	BOOL					replayValidWord;
	int						replayIndex;
	
	NSString*				_addWordCandidate;
										
										
	int						pauseOnWordCount;
	int						pauseOnWordCountIncrement;
	
	CSetWrapper*			_blackList;
	CSetWrapper*			_hintBlackList;
										
	BOOL					allowDupWords;
	BOOL					allowPlayPause;
	BOOL					allowShowHint;
	BOOL					allowReselectPartialDeselect;
	BOOL					allowAddWords;
	
	
	// new preferences model starts here
	int						showHintDelay;
	int						betweenHintDelay;
	BOOL					speakHintWord;
	BOOL					showHintWord;
	BOOL					showHintImage;
	BOOL					showHintText;
	BOOL					showHintPieces;
	int						hintMaxWordSize;
	
	BOOL					speakRewardWord;
	BOOL					showRewardImage;
	BOOL					showRewardText;
	
	float					flashAttackDuration;
	float					flashAttackAlpha;
	float					flashSustainDuration;
	float					flashSustainAlpha;
	float					flashDecayDuration;
	float					flashDecayAlpha;
	
	NSString*				_rushSymbols;
	int						rushWords;
	int						rushMinWordSize;
	int						rushMaxWordSize;
	float					rushDispensingFactor;
	
	BOOL					hintPending;
	int						hintWordCount;
	BOOL					hintWordCountAtleast;
	BOOL					showHintWordCount;
	
	SplashPanel*			_helpSplashPanel;
	SplashPanel*			_textSplashPanel;
	SplashPanel*			_summarySplashPanel;
	
	NSDictionary*			_props;
	
	GameLevelSequence*		_seq;
								
	BOOL					autorun;
	BOOL					autorunAccumulateScore;
	AutoMaxWordSizeBehaviorType	autoMaxWordSizeBehavior;
	BOOL					autoValidWordWipe;
	
	NSMutableArray*			_commitWords;
	NSString*				_commitWordCandidate;
	
	int						validWordCount;
	
	BOOL					showSummarySplash;
	
	float					scoreFactor;
	
	BOOL					jokerImageHints;
	BOOL					jokerImageRewards;
	
	BOOL					showLanguageBackground;
	
	BOOL					levelEndMenu;
	int						levelEndContinueRemainingWordCountThreshold;
	NSSet*					_initialBlackList;
	
	
	BOOL					f_boardFullNoHint;
	
	id<Board>				_hintBoard;
	
	int						lastGeneratedHintWordIndex;
	
	int						boardFullWarnBudget;
	int						boardFullWarnLeft;
	int						boardFullWarnCost;
	
	BOOL					fastGame;
	
	int						boardWordCountResult;
	
	BOOL					fullHint;
	BOOL					manualHint;
										
}
@property BOOL loadDefaultLanguage;
@property BOOL loadDefaultBoard;
@property BOOL loadDefaultDispenser;
@property BOOL loadDefaultLogic;

@property (retain) id<Board> board;
@property (retain) id<PieceDispenser> dispenser;
@property (retain) id<Language> language;
@property (retain) id<WordValidator> wordValidator;
@property (retain) NSTimer* tickTimer;
@property (retain) GameLevelView* view;
@property (retain) id<PiecesHint> piecesHint;
@property (retain) NSString* hintWord;
@property (nonatomic,assign) id<GameLevelEventsTarget> eventsTarget;
@property (retain) SoundTheme* soundTheme;
@property (retain) ScoreWidget* scoreWidget;
@property (readonly) int score;
@property (retain) NSString* title;
@property (retain) NSString* shortDescription;
@property int minWordSize;
@property (retain) NSMutableArray* currentWordPieces;
@property (retain) id<GameBoardLogic> logic;

@property int gameOverGrace;
@property int gameWonGrace;
@property int pausedGrace;
@property int idleToHintGrace;

@property BOOL allowDupWords;

@property (retain) NSMutableDictionary*	selectedWords;	
@property (retain) NSString* uuid;
@property BOOL showWordImageOnDispensed;
@property BOOL showWordImageOnValid;
@property BOOL speakWordOnDispensed;
@property BOOL replayValidWord;
@property BOOL allowReselectPartialDeselect;
@property BOOL allowAddWords;

@property (retain) NSString* addWordCandidate;
@property int pauseOnWordCount;
@property int pauseOnWordCountIncrement;

@property (retain) CSetWrapper* blackList;
@property (retain) CSetWrapper* hintBlackList;

@property BOOL allowPlayPause;
@property BOOL allowShowHint;

// new preferences model starts here
@property int showHintDelay;
@property int betweenHintDelay;
@property BOOL speakHintWord;
@property BOOL showHintWord;
@property BOOL showHintImage;
@property BOOL showHintText;
@property BOOL showHintPieces;
@property int hintMaxWordSize;

@property BOOL speakRewardWord;
@property BOOL showRewardImage;
@property BOOL showRewardText;

@property float flashAttackDuration;
@property float flashAttackAlpha;
@property float flashSustainDuration;
@property float flashSustainAlpha;
@property float flashDecayDuration;
@property float flashDecayAlpha;

@property (retain) NSString* rushSymbols;
@property int rushWords;
@property int rushMinWordSize;
@property int rushMaxWordSize;
@property float rushDispensingFactor;
@property (retain) SplashPanel* helpSplashPanel;
@property (retain) SplashPanel* textSplashPanel;
@property (retain) SplashPanel* summarySplashPanel;

@property (retain) NSDictionary* props;
@property (nonatomic,assign) GameLevelSequence* seq;

@property GameLevelState state;

@property (retain) NSMutableArray* commitWords;
@property (retain) NSString* commitWordCandidate;

@property BOOL showSummarySplash;
@property float scoreFactor;
@property BOOL autorun;
@property AutoMaxWordSizeBehaviorType autoMaxWordSizeBehavior;
@property BOOL autoValidWordWipe;


@property (retain) NSMutableArray* stateWhenSuspended;

@property BOOL jokerImageHints;
@property BOOL jokerImageRewards;
@property BOOL showLanguageBackground;
@property BOOL levelEndMenu;
@property int levelEndContinueRemainingWordCountThreshold;
@property (retain) NSSet* initialBlackList;

@property (retain) id<Board> hintBoard;

@property int boardFullWarnLeft;
@property int boardFullWarnBudget;
@property int boardFullWarnCost;

@property BOOL fastGame;


-(void)loadGame;
-(void)startGame;
-(void)pauseGame;
-(void)resumeGame;
-(void)suspendGame;
-(void)suspendGameWithAutomaticResumeAfter:(int)seconds;
-(void)stopGame;
-(NSString*)getCurrentWord;
-(int)getCurrentScore;

// privates
-(void)gameOverAlert;
-(void)gameOverAlert_Part2;
-(void)gameOverAlert_Part3;
-(void)gameWonAlert;
-(void)gameWonAlert_Part2;
-(void)gameWonAlert_Part3;
-(void)resetCurrentWordPieces;

-(void)generateHint:(id)sender;
-(void)resetHint;

-(int)validSelectedWordCount;
-(NSSet*)validSelectedWords;
-(int)languageWordCount;

-(void)shaken;

-(void)showHelpSplash;


@end
