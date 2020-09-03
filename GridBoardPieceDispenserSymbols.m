//
//  GridBoardPieceDispenserSymbols.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoardPieceDispenserSymbols.h"
#import "SymbolPiece.h"
#import "JokerUtils.h"


@implementation GridBoardPieceDispenserSymbols
@synthesize symbolDispenser = _symbolDispenser;
@synthesize rushDispensingFactor;
@synthesize jokerProb;
@synthesize jokerURS = _jokerURS;

-(id)init
{
	if ( self = [super init] )
	{
		jokerProb = [JokerUtils globalJokerProb];
		self.jokerURS = [[[SingleProbabilityURS alloc] initWithProbability:jokerProb] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[_symbolDispenser release];
	[_jokerURS release];
	
	[super dealloc];
}

-(BOOL)preparePiece
{
	if ( [_symbolDispenser canDispense] )
	{
		NSMutableDictionary*	hints = [NSMutableDictionary dictionary];
		unichar					symbol = [_symbolDispenser dispense:hints];
		if ( symbol == NO_SYMBOL )
			return FALSE;
		UIImage*		image = NULL;
		unichar			originalSymbol = 0;
		
		if ( symbol == [JokerUtils jokerCharacter] )
			originalSymbol = symbol;
		else if ( [_jokerURS next] )
		{
			originalSymbol = symbol;
			symbol = [JokerUtils jokerCharacter];
			image = [JokerUtils jokerImage];
			
		}
		SymbolPiece*	piece = [self piece:symbol withImage:image];
		if ( originalSymbol )
			[piece.props setObject:[NSString stringWithCharacters:&originalSymbol length:1] forKey:@"OriginalSymbol"];
		
		id<Piece>		leadingPiece = [hints objectForKey:@"LeadingPiece"];
		if ( leadingPiece )
			[piece.props setObject:leadingPiece forKey:@"LeadingPiece"];
		
		[_ownBoard placePiece:piece at:0];
		
		return TRUE;
	}
	else
		return FALSE;
}

-(float)progress
{
	return [_symbolDispenser progress];
}

-(int)piecesLeft
{
	return [_symbolDispenser symbolsLeft];
}

-(float)nextTickPeriod
{
	BOOL		rushDispensing = [_symbolDispenser rushDispensing];
	float		period;
	
	// make first non-rush reset the rush dispensing factor ...
	if ( !rushDispensing )
		rushDispensingFactor = 0.0;
	
	if ( (rushDispensing || lastRushDispensing) && (rushDispensingFactor > 0.0) )
		period = [super nextTickPeriod] / rushDispensingFactor;
	else
		period = [super nextTickPeriod];
	
	lastRushDispensing = rushDispensing;
	
	return period;
}

-(void)setJokerProb:(float)jokerProb_param
{
	jokerProb = jokerProb_param;
	[_jokerURS setProbability:jokerProb];
}

-(void)setBoard:(GridBoard*)board
{
	if ( [_symbolDispenser respondsToSelector:@selector(setBoard:)] )
		[_symbolDispenser performSelector:@selector(setBoard:) withObject:board];
}


@end
