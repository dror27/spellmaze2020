//
//  GridBoardPieceDispenserBase.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoardPieceDispenserBase.h"
#import "SymbolPiece.h"
#import "PieceDispensingHintsImpl.h"
#import "UserPrefs.h"
#import "NSDictionary_TypedAccess.h"
#import "BrandManager.h"


#import <math.h>

static BOOL		local_log = FALSE;

//#define		ALLOC_COUNT
#ifdef		ALLOC_COUNT
static int			initCount;
static int			deallocCount;
#endif


@implementation GridBoardPieceDispenserBase
@synthesize ownBoard = _ownBoard;
@synthesize dispensingTickTimer = _dispensingTickTimer;
@synthesize dispensingTickPeriod;
@synthesize boardFullnessTickPeriodFactor;
@synthesize boardFullnessTickPeriodCurve;
@synthesize boardProgressTickPeriodFactor;
@synthesize dispenserProgressTickPeriodFactor;
@synthesize view = _view;
@synthesize target = _target;

-(id)init
{
	if ( self = [super init] )
	{
		boardFullnessTickPeriodFactor = 0.75;
		boardFullnessTickPeriodCurve = -0.5;
		boardProgressTickPeriodFactor = 0.25;
		dispenserProgressTickPeriodFactor = 0.0;
		self.ownBoard = [[[GridBoard alloc] initWithWidth:1 andHeight:1] autorelease];
		[_ownBoard setPiecesSelectable:FALSE];
		gameSpeed = [UserPrefs getFloat:PK_GAME_SPEED withDefault:1];
		//NSLog(@"gameSpeed: %f", gameSpeed);		

#ifdef	ALLOC_COUNT
		initCount++;
		NSLog(@"[GridBoardPieceDispenserBase-%p] init: init/dealloc = %d/%d", self, initCount, deallocCount);
#endif
		
	}
	return self;
}

#ifdef ALLOC_COUNT
-(id)retain
{
	NSLog(@"[GridBoardPieceDispenserBase-%p] retain", self);
	return [super retain];
}
-(void)release
{
	NSLog(@"[GridBoardPieceDispenserBase-%p] release", self);
	[super release];
}
-(id)autorelease
{
	NSLog(@"[GridBoardPieceDispenserBase-%p] autorelease", self);
	return [super autorelease];
}
#endif


-(void)dealloc
{
#ifdef	ALLOC_COUNT
	deallocCount++;
	NSLog(@"[GameLevel-%p] dealloc: init/dealloc = %d/%d", self, initCount, deallocCount);
#endif

	[_ownBoard release];
	[_dispensingTickTimer release];
	
	[_view setModel:nil];
	[_view release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( _view == NULL )
		self.view = [[[GridBoardPieceDispenserView alloc] initWithFrame:frame andModel:self] autorelease];
	return _view;
}

-(void)startTimer
{
	float		period = [self nextTickPeriod];
	
	// needs to adjsut speed?
	if ( boardFullnessTickPeriodFactor != 0.0 )
	{
		// get indicator of fullness
		float	fullness = [_target targetFullness];
		if (( local_log )) NSLog(@"fullness:%f", fullness);
		
		// calculate curve factor (move from {-1.0,1.0} to {1.0,0.0}
		float	curve = 1.0 - ((boardFullnessTickPeriodCurve + 1) / 2);
		if (( local_log )) NSLog(@"curve:%f", curve);

		// calculate direction: postive:multiplier increases as board is freer
		float	direction = (boardFullnessTickPeriodFactor > 0) ? 1.0 : -1.0;
		if ( direction < 0 )
			fullness = 1.0 - fullness;

		// calculate exponential multiplier - depending on fullness {0.0,1.0} -> {BIG,0.0}
		float	multiplier = (expf(1.0 / (fullness + curve)) / expf(1.0 / (1.0 + curve))) - 1.0;
		if (( local_log )) NSLog(@"multiplier:%f", multiplier);
		
		// calculate magnitude factor (volume) - same math as multiplier, with a onstant curve
		float	factor = (expf(1.0 / ((1 - fabsf(boardFullnessTickPeriodFactor)) + 0.5)) / expf(1.0 / 1.5)) - 1.0;
		if (( local_log )) NSLog(@"factor:%f", factor);
		
		// finally, a volume control ..
		float	volume = factor * multiplier;
		if (( local_log )) NSLog(@"volume:%f", volume);
	
		float	originalPeriod = period;
		if ( direction > 0 )
			period /= (1.0 + volume);
		else
			period /= (1.0 + volume);
		
		if (( local_log )) NSLog(@"variablePeriod: (fullness:%f) %f -> %f", fullness, originalPeriod, period);
	}
	
	// reduce on target progress?
	if ( boardProgressTickPeriodFactor != 0.0 )
	{
		float	progress = [_target targetProgress];
		float	factor = pow(1.0 - boardProgressTickPeriodFactor, progress);
		
		period *= factor;
		if (( local_log )) NSLog(@"boardProgress: (progress:%f, factor:%f) -> %f", progress, factor, period);
	}

	// reduce on self progress?
	if ( dispenserProgressTickPeriodFactor != 0.0 )
	{
		float	progress = [self progress];
		float	factor = pow(1.0 - dispenserProgressTickPeriodFactor, progress);
		
		period *= factor;
		if (( local_log )) NSLog(@"dispenserProgress: (progress:%f, factor:%f) -> %f", progress, factor, period);
	}
	
	period /= gameSpeed;
	if (( local_log )) NSLog(@"period: %f", period);
	self.dispensingTickTimer = [NSTimer scheduledTimerWithTimeInterval:period target:self selector:@selector(onTimer) userInfo:nil repeats:NO]; 		
}

-(void)stopTimer
{
	if ( _dispensingTickTimer != NULL )
	{
		if ( [_dispensingTickTimer isValid] )
			[_dispensingTickTimer invalidate];
		
		self.dispensingTickTimer = NULL;
	}
}

-(BOOL)preparePiece
{
	return FALSE;
}

-(BOOL)dispense
{
	// peek at current piece
	id<Piece>	piece = [_ownBoard pieceAt:0];
	if ( piece == NULL )
	{
		// no more pieces
		[_target onNoMorePieces];
		dispensing = FALSE;
		return FALSE;
	}
	
	// dispense only if target will accept
	if ( [_target onWillAcceptPiece] )
	{
		piece = [_ownBoard placePiece:NULL at:0];

		// inform target of the new piece
		[_target onPieceDispensed:piece withContext:_context];
		
		// prepare next piece
		[self preparePiece];

		return TRUE;
	}
	else
	{
		dispensing = FALSE;
		return FALSE;
	}
}

-(void)onTimer
{
	self.dispensingTickTimer = FALSE;
	
	if ( dispensing )
		if ( [self dispense] )
			if ( dispensing )
				[self startTimer];
}

-(void)startDispensing:(id<PieceDispensingTarget>)target andContext:(void*)context
{
	// stop timer if running
	[self stopTimer];
	
	// init target
	self.target = target;
	_context = context;
	[_target onDispensingStarted];
	
	// prepare the first piece
	[self preparePiece];

#if 0
	// dispense the first piece, start timer if successful
	dispensing = TRUE;
	if ( [self dispense] )
	{
		if ( dispensing )
			[self startTimer];
	}
#else
	dispensing = TRUE;
	[self startTimer];
#endif
}

-(void)stopDispensing
{
	dispensing = FALSE;
	
	// stop timer if runniung
	[self stopTimer];
	
	// notify target
	[_target onDispensingStopped];
}

-(void)resumeDispensing
{
	[self stopTimer];
	
	dispensing = TRUE;
#if 0
	[self startTimer];
#else
	if ( [self dispense] )
	{
		if ( dispensing )
			[self startTimer];
	}
#endif
}

-(float)progress
{
	return 0;
}

-(int)piecesLeft
{
	return 0;
}

-(float)nextTickPeriod
{
	return dispensingTickPeriod;
}

-(SymbolPiece*)piece:(unichar)symbol withImage:(UIImage*)image
{
	SymbolPiece*		piece = [[[SymbolPiece alloc] init] autorelease];
	
	// basic stuff
	piece.symbol = symbol;
	piece.image = image;
	
	// if already has image, not much we can add ...
	if ( image )
		return piece;
	
	// check with language for image
	id<Language>		language = [_target targetLanguage];
	piece.image = [language symbolImage:symbol];
	if ( piece.image )
	{
		piece.showSymbolText = [language showSymbolTextOnSymbolImage];
		return piece;
	}	
	
	// check with brand
	Brand*			brand = [BrandManager currentBrand];
	piece.image = [brand globalImage:[NSString stringWithFormat:@"symbols_%C", symbol] withDefaultValue:NULL];
	if ( piece.image )
	{
		piece.showSymbolText = [brand globalBoolean:@"skin/props/show-symbol-text" withDefaultValue:TRUE];
		return piece;
	}
	
	return piece;
}

@end
