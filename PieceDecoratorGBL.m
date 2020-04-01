//
//  PieceDecoratorGBL.m
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

/*
 * Logic:
 *
 *
 *	APPLE - install a random decoration on another piece of the board
 *	COIN - buy time, pause the game for 4 seconds
 *	BOMB - eliminate pieces around the piece
 */

#import "PieceDecoratorGBL.h"
#import "NSDictionary_TypedAccess.h"
#import "Cell.h"
#import "GridBoard.h"
#import "SoundTheme.h"
#import "Board.h"
#import "GameLevel.h"
#import "UserPrefs.h"
#import "SymbolPiece.h"
#import "Wallet.h"
#import "JokerUtils.h"
#import "RoleManager.h"


#define APPLE_MULT	1.25
#define	COIN_MULT	1.0
#define BOMB_MULT	1.0

//#define	TEST_EXTREME_1

#ifndef TEST_EXTREME_1
#define	APPLE_PROB				0.1
#define	COIN_PROB				0.05
#define	BOMB_PROB				0.05
#define	APPLE_DECORATION_DELAY	0.4
#define	BOMB_EXPLOSION_DELAY	0.4
#else
#define	APPLE_PROB				0.35
#define	COIN_PROB				0.05
#define	BOMB_PROB				0.35
#define	APPLE_DECORATION_DELAY	10.0
#define	BOMB_EXPLOSION_DELAY	10.0
#endif
@interface PieceDecoratorGBL (Privates)
-(NSArray*)bombedNeighbors:(NSArray*)pieces;
-(void)addBombToEliminationCandidateTo:(NSMutableSet*)candidates atX:(int)x andY:(int)y onBoard:(GridBoard*)board;
-(NSString*)randomDecoration:(BOOL)optional;
@end


@implementation PieceDecoratorGBL
@synthesize decorations = _decorations;

-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super initWithBoard:board] )
	{
		if ( !CHEAT_ON(CHEAT_DISABLE_ALL_DECORATIONS) )
		{
			NSMutableDictionary*	d = [[[NSMutableDictionary alloc] init] autorelease];
			
			if ( APPLE_PROB > 0 )
				[d setObject:[NSNumber numberWithFloat:APPLE_PROB] forKey:DECORATOR_APPLE];
			if ( COIN_PROB > 0 )
				[d setObject:[NSNumber numberWithFloat:COIN_PROB] forKey:DECORATOR_COIN];
			if ( BOMB_PROB > 0 )
				[d setObject:[NSNumber numberWithFloat:BOMB_PROB] forKey:DECORATOR_BOMB];
			
			self.decorations = d;
		}
	}
	return self;
}

-(void)dealloc
{
	[_decorations release];
	
	[super dealloc];
}

-(void)setDecoration:(NSString*)decoration withProb:(float)prob
{
	if ( !_decorations )
		self.decorations = [NSDictionary dictionary];
	
	NSMutableDictionary*	d = [NSMutableDictionary dictionaryWithDictionary:self.decorations];
	[d setObject:[NSNumber numberWithFloat:prob] forKey:decoration];
	
	self.decorations = d;
}

-(void)setDecorations:(NSDictionary*)decorations
{
	[_decorations autorelease];
	_decorations = [decorations retain];
	
	_probSum = 0;
	if ( _decorations )
		for ( NSNumber* n in [_decorations allValues] )
			_probSum += [n floatValue]; 
}

-(NSString*)role
{
	return @"Decoration";
}

-(void)pieceDispensed:(id<Piece>)piece
{
	if ( _decorations )
	{
		NSString*	decoration = [self randomDecoration:TRUE];
		
		if ( decoration )
			[piece addDecorator:decoration];
	}
}

-(int)scoreSuggested:(int)score forPieces:(NSArray*)pieces;
{
	int			apples = 0, coins = 0, bombs = 0;
	SoundTheme*	soundTheme = [[_board level] soundTheme];
	Wallet*		wallet = [Wallet singleton];
	BOOL		appleSuperSound = FALSE;
	BOOL		coinSuperSound = FALSE;
	BOOL		bombSuperSound = FALSE;
	double		dscore = score;
	
	// integrate decoration bonuses
	for ( id<Piece> piece in pieces )
	{
		if ( [piece hasDecorator:DECORATOR_APPLE] )
		{
			if ( ![JokerUtils pieceIsJoker:piece] )
			{
				apples++;
				dscore *= APPLE_MULT;
			}
			appleSuperSound |= [wallet incrWalletItemValue:DECORATOR_APPLE incr:apples];
		}
		if ( [piece hasDecorator:DECORATOR_COIN] )
		{
			if ( ![JokerUtils pieceIsJoker:piece] )
			{
				coins++;
				dscore *= COIN_MULT;
			}
			coinSuperSound |= [wallet incrWalletItemValue:DECORATOR_COIN incr:coins];
		}
		if ( [piece hasDecorator:DECORATOR_BOMB] )
		{
			if ( ![JokerUtils pieceIsJoker:piece] )
			{
				bombs++;
				dscore *= BOMB_MULT;
			}
			bombSuperSound |= [wallet incrWalletItemValue:DECORATOR_BOMB incr:bombs];
		}
	}
	
	// integrate full house 
	if ( apples == [pieces count] )
	{
		appleSuperSound |= [wallet incrWalletItemValue:DECORATOR_APPLE incr:apples];
		appleSuperSound = TRUE;
		while ( apples-- )
			dscore *= APPLE_MULT;
	}
	if ( coins == [pieces count] )
	{
		coinSuperSound |= [wallet incrWalletItemValue:DECORATOR_COIN incr:coins];
		coinSuperSound = TRUE;
		while ( coins-- )
			dscore *= COIN_MULT;
	}
	if ( bombs == [pieces count] )
	{
		bombSuperSound |= [wallet incrWalletItemValue:DECORATOR_BOMB incr:bombs];
		bombSuperSound = TRUE;
		while ( bombs-- )
			dscore *= BOMB_MULT;
	}
	if ( appleSuperSound )
		[soundTheme performSelector:@selector(decorationExtra:) withObject:DECORATOR_APPLE afterDelay:0.3];
	if ( coinSuperSound )
		[soundTheme performSelector:@selector(decorationExtra:) withObject:DECORATOR_COIN afterDelay:0.3];
	if ( bombSuperSound )
		[soundTheme performSelector:@selector(decorationExtra:) withObject:DECORATOR_BOMB afterDelay:0.3];		
	
	// left over sounds
	if ( bombs )
		[soundTheme performSelector:@selector(decoration:) withObject:DECORATOR_BOMB afterDelay:0.4];
	else if ( coins )
		[soundTheme performSelector:@selector(decoration:) withObject:DECORATOR_COIN afterDelay:0.6];
	else if ( apples )
		[soundTheme performSelector:@selector(decoration:) withObject:DECORATOR_APPLE afterDelay:0.2];
	
	//NSLog(@"scoreSuggested: %d", score);
	
	return round(dscore);
}

-(NSArray*)eliminationSuggested:(NSArray*)pieces
{
	// apple processing
	NSMutableArray*		allPieces = NULL;
	for ( id<Piece> piece in pieces )
		if ( [piece hasDecorator:DECORATOR_APPLE] )
		{
			// get a new decorator
			NSString*	decorator = [self randomDecoration:FALSE];
			if ( !decorator )
				continue;
			
			// get a random piece on the board which is not already decorated
			if ( !allPieces )
			{
				allPieces = [NSMutableArray arrayWithArray:[_board allPieces]];
				for ( int index = 0 ; index < [allPieces count] ; )
				{
					id<Piece>	p = [allPieces objectAtIndex:0];
					
					if ( [pieces containsObject:p] || [p hasDecorator:NULL] )
						[allPieces removeObjectAtIndex:index];
					else
						index++;
				}
			}
			if ( !allPieces || ![allPieces count] )
				break;
			int			index = rand() % [allPieces count];
			id<Piece>	randomPiece = [allPieces objectAtIndex:index];
			
			// decorate it
			[self performSelector:@selector(addDecoratorToPiece:) 
							withObject:[NSArray arrayWithObjects: decorator, randomPiece, NULL] afterDelay:APPLE_DECORATION_DELAY];
			[allPieces removeObject:randomPiece];
		}
	
	// coin processing
	double	coinsPause = 0;
	int		coins = 0;
	for ( id<Piece> piece in pieces )
		if ( [piece hasDecorator:DECORATOR_COIN] && ![JokerUtils pieceIsJoker:piece] )
		{
			coinsPause += 3;
			coins++;
		}
	if ( coins == [pieces count] )
		coinsPause *= 1.5;
	if ( coinsPause > 0.0 )
		[[_board level] suspendGameWithAutomaticResumeAfter:round(coinsPause)];
	
	// bomb processing
	NSArray*		bombedNeighbors = [self bombedNeighbors:pieces];
	if ( [bombedNeighbors count] )
	{
		[self performSelector:@selector(eliminatePieces:) withObject:[NSArray arrayWithObjects:bombedNeighbors,[[_board level] soundTheme], NULL] afterDelay:BOMB_EXPLOSION_DELAY]; 
	}
	
	return pieces;
}

-(void)addDecoratorToPiece:(NSArray*)params
{
	NSString*		decorator = [params objectAtIndex:0];
	id<Piece>		piece = [params objectAtIndex:1];
	
	[piece addDecorator:decorator];
}

-(void)eliminatePieces:(NSArray*)params
{
	NSArray*		pieces = [params objectAtIndex:0];
	SoundTheme*		soundTheme = [params objectAtIndex:1];
	NSArray*		bombedNeighbors = [self bombedNeighbors:pieces];
	
	if ( [bombedNeighbors count] )
		[self performSelector:@selector(eliminatePieces:) withObject:[NSArray arrayWithObjects:bombedNeighbors,soundTheme,NULL] afterDelay:BOMB_EXPLOSION_DELAY]; 

	if ( [pieces count] )
		[soundTheme decoration:DECORATOR_BOMB];
	for ( id<Piece> piece in pieces )
		[piece eliminate];	
}

-(NSArray*)bombedNeighbors:(NSArray*)pieces
{
	NSMutableSet*		newPieces = NULL;
	NSMutableArray*		bombPieces = [NSMutableArray array];

	// collect (real) bomb piece
	for ( id<Piece> piece in pieces )
		if ( [piece hasDecorator:DECORATOR_BOMB] && ![JokerUtils pieceIsJoker:piece] )
			[bombPieces addObject:piece];
	
	BOOL				allBombs = [bombPieces count] == [pieces count];
	
	// implement bomb effect
	for ( id<Piece> piece in bombPieces )
	{
		// find sounding pieces
		Cell*		cell = [piece cell];
		if ( cell && [[cell board] isKindOfClass:[GridBoard class]] )
		{
			GridBoard*	board = [cell board];
			int			x = cell.x;
			int			y = cell.y;
			
			if ( !newPieces )
			{
				newPieces = [[[NSMutableSet alloc] init] autorelease];
				[newPieces addObjectsFromArray:pieces];					
			}
			
			for ( int dx = -1 ; dx <= 1 ; dx++ )
				for ( int dy = -1 ; dy <= 1 ; dy++ )
					if ( dx || dy )
					{
						BOOL	add;
						
						// if not all bomb, bomb only on cross (dx == 0 || dy == 0)
						if ( !allBombs )
							add = (dx == 0) || (dy == 0);
						else
							add = TRUE;
						
						if ( add )
							[self addBombToEliminationCandidateTo:newPieces atX:x+dx andY:y+dy onBoard:board];
					}
		}
		
	}
	
	if ( newPieces )
		for ( id x in pieces )
			[newPieces removeObject:x];
	
	return newPieces ? [newPieces allObjects] : [NSArray array];
}

-(void)addBombToEliminationCandidateTo:(NSMutableSet*)candidates atX:(int)x andY:(int)y onBoard:(GridBoard*)board
{
	if ( x < 0 || x >= [board width] )
		return;
	if ( y < 0 || y >= [board height] )
		return;
	
	Cell*	cell = [board cellAt:x andY:y];
	if ( cell )
	{
		id<Piece>	piece = [cell piece];
		
		if ( piece && ![candidates containsObject:piece] )
		{
			[candidates addObject:piece];
		}
	}
}

-(NSString*)randomDecoration:(BOOL)optional
{
	float	v = (float)rand() / RAND_MAX;
	if ( !optional )
		v /= _probSum;
	
	for ( NSString* decoration in [_decorations allKeys] )
	{
		v -= [_decorations floatForKey:decoration withDefaultValue:0.0];
		if ( v <= 0 )
		{
			return decoration;
		}
	}	
	
	return optional ? NULL : [[_decorations allKeys] objectAtIndex:0];
}
@end
