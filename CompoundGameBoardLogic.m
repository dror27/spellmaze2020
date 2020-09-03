//
//  CompoundGameBoardLogic.m
//  Board3
//
//  Created by Dror Kessler on 5/25/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "CompoundGameBoardLogic.h"
#import "CSetWrapper.h"

//HACK
//#define MEASURE
#ifdef	MEASURE
static clock_t		startedAt;
#endif


@implementation CompoundGameBoardLogic
@synthesize logics = _logics;

-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super initWithBoard:board] )
	{
		self.logics = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[_logics release];
	
	[super dealloc];
}

-(void)add:(id<GameBoardLogic>)logic
{
	// make sure no other logic from this role exists if the role is exlusive
	NSString*		role = [logic role];
	if ( role && [role length] && [role characterAtIndex:[role length] - 1] == '!' )
	{
		for ( int index = 0 ; index < [_logics count] ; )
		{
			id<GameBoardLogic>	l = [_logics objectAtIndex:index];
			
			if ( [role isEqualToString:[l role]] )
				[_logics removeObjectAtIndex:index];
			else
				index++;
		}
	}
	
	// finally add it
	[_logics addObject:logic];
}

-(int)count
{
	return [_logics count];
}

-(BOOL)willAcceptPiece
{
	for ( id<GameBoardLogic> logic in _logics )
		if ( ![logic willAcceptPiece] )
			return FALSE;
	
	return TRUE;
}

-(void)pieceDispensed:(id<Piece>)piece
{
	if ( [piece.props objectForKey:@"LeadingPiece"] )
	{
		[[self getIncludedRole:@"Disable!"] pieceDispensed:piece];
	}
	else
	{
		for ( id<GameBoardLogic> logic in _logics )
			[logic pieceDispensed:piece];
	}
}

-(void)pieceSelected:(id<Piece>)piece
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic pieceSelected:piece];	
}

-(void)pieceReselected:(id<Piece>)piece
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic pieceReselected:piece];	
}

-(void)validWordSelected:(NSString*)word
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic validWordSelected:word];	
}

-(void)invalidWordSelected:(NSString*)word
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic invalidWordSelected:word];
}

-(void)wordSelectionCanceled
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic wordSelectionCanceled];
}


-(void)onGameTimer
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic onGameTimer];	
}

-(void)onFineGameTimer
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic onFineGameTimer];	
}

-(void)onGameWon
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic onGameWon];	
}

-(void)onGameOver
{
	for ( id<GameBoardLogic> logic in _logics )
		[logic onGameOver];	
}

-(int)scoreSuggested:(int)score forPieces:(NSArray*)pieces
{
	for ( id<GameBoardLogic> logic in _logics )
		score = [logic scoreSuggested:score forPieces:pieces];

	return score;
}

-(NSArray*)eliminationSuggested:(NSArray*)pieces
{
	for ( id<GameBoardLogic> logic in _logics )
		pieces = [logic eliminationSuggested:pieces];

	
	return pieces;
}

-(CSetWrapper*)generateBoardWordSet:(NSMutableArray**)piecesOutput 
						   forBoard:(id<Board>)board 
				  withWordValidator:(id<WordValidator>)wordValidator 
					withMinWordSize:(int)minWordSize andMaxWordSize:(int)maxWordSize 
					   andBlackList:(CSetWrapper*)blackList
{
#ifdef MEASURE
	// HACK!!
	startedAt = clock();
#endif

#ifdef	MEASURE
	NSLog(@"[CompoundGBL] %f started", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif		
	
	int		logicsNum = [_logics count];
	
	if ( !logicsNum )
	{
		CSetWrapper*	result = [[[CSetWrapper alloc] init] autorelease];

#ifdef	MEASURE
		NSLog(@"[CompoundGBL] %f finished (0 logics)", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif
		
		return result;
	}
	else if ( logicsNum == 1 )
	{
		id<GameBoardLogic>	logic = [_logics objectAtIndex:0];
		CSetWrapper*		result = [logic generateBoardWordSet:piecesOutput forBoard:board withWordValidator:wordValidator withMinWordSize:minWordSize andMaxWordSize:maxWordSize andBlackList:blackList];

#ifdef	MEASURE
		NSLog(@"[CompoundGBL] %f finished (1 logics)", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif		
		return result;
	}
	else
	{
		// must word hard ... collect word sets. make sure we get only one of each
		NSMutableDictionary*		wordSets = [NSMutableDictionary dictionary];
		for ( id<GameBoardLogic> logic in _logics )
		{
			NSString*		role = [logic generateBoardWordSetRole];
			if ( [wordSets objectForKey:role] )
				continue;
			
			CSetWrapper*	wordSet = [logic generateBoardWordSet:piecesOutput forBoard:board withWordValidator:wordValidator withMinWordSize:minWordSize andMaxWordSize:maxWordSize andBlackList:blackList];
			
			[wordSets setObject:wordSet forKey:role];

#ifdef	MEASURE
			NSLog(@"[CompoundGBL] %f wordset for role %@ (%d words)", (float)(clock() - startedAt) / CLOCKS_PER_SEC, role, wordSet.cs->size);
#endif		
		}
		
		// intersect (all logics must agree ...)
		int					csNum = [wordSets count];
		if ( csNum == 1 )
		{
			CSetWrapper*	result = [[wordSets allValues] objectAtIndex:0];
			
#ifdef	MEASURE
			NSLog(@"[CompoundGBL] %f finished (2+ logics, single role)", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif				
			return result;
		}
		
		CSetWrapper*		result = [[[CSetWrapper alloc] init] autorelease];
		CSet**				csVec = alloca(sizeof(CSet*) * csNum);
		int					csIndex = 0;
		for ( CSetWrapper* csw in [wordSets allValues] )
			csVec[csIndex++] = csw.cs;
		CSet_Intersect(csVec, csNum, result.cs);
		
#ifdef	MEASURE
		NSLog(@"[CompoundGBL] %f finished (2+ logics, multiple roles)", (float)(clock() - startedAt) / CLOCKS_PER_SEC);
#endif		
		return result;
	}
}

-(BOOL)includesRole:(NSString*)role
{
	for ( id<GameBoardLogic> logic in _logics )
		if ( [logic includesRole:role] )
			return TRUE;
	
	return FALSE;
}

-(id<GameBoardLogic>)getIncludedRole:(NSString*)role
{
	for ( id<GameBoardLogic> logic in _logics )
		if ( [logic includesRole:role] )
			return [logic getIncludedRole:role];
	
	return nil;
}


-(void)setBoard:(id<Board>)board
{
	for ( id<GameBoardLogic> logic in _logics )
		if ( [logic respondsToSelector:@selector(setBoard:)] )
			[logic performSelector:@selector(setBoard:) withObject:board];
}

@end
