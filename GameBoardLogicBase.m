//
//  GameBoardLogicBase.m
//  Board3
//
//  Created by Dror Kessler on 5/25/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GameBoardLogicBase.h"


@implementation GameBoardLogicBase
@synthesize board = _board;

-(id)initWithBoard:(id<Board>)board
{
	if ( self = [super init] )
	{
		self.board = board;
	}
	return self;
}

-(void)dealloc
{
	[_board release];
	
	[super dealloc];
}

-(BOOL)willAcceptPiece
{
	return TRUE;
}

-(void)pieceDispensed:(id<Piece>)piece
{
	
}

-(void)pieceSelected:(id<Piece>)piece
{
	
}

-(void)pieceReselected:(id<Piece>)piece
{
	
}

-(void)validWordSelected:(NSString*)word
{
	
}

-(void)invalidWordSelected:(NSString*)word
{
	
}

-(void)wordSelectionCanceled
{
	
}

-(int)scoreSuggested:(int)score forPieces:(NSArray*)pieces;
{
	return score;
}

-(NSArray*)eliminationSuggested:(NSArray*)pieces
{
	return pieces;
}

-(void)onGameTimer
{
	
}

-(void)onFineGameTimer
{
	
}

-(void)onGameWon
{
	
}

-(void)onGameOver
{
	
}


-(NSString*)role
{
	return @"";
}

-(CSetWrapper*)generateBoardWordSet:(NSMutableArray**)piecesOutput forBoard:(id<Board>)board withWordValidator:(id<WordValidator>)wordValidator withMinWordSize:(int)minWordSize andMaxWordSize:(int)maxWordSize andBlackList:(CSetWrapper*)blackList
{
	CSetWrapper		*wordsSet = NULL;	
	
	// get pieces on the board
	NSMutableArray		*pieces = [[[NSMutableArray alloc] initWithArray:[board allPieces]] autorelease];
	if ( piecesOutput )
		*piecesOutput = pieces;
	
	// extract symbols
	NSMutableString *symbols = [[[NSMutableString alloc] init] autorelease];
	for ( id<Piece> piece in pieces )
	{
		NSString*	originalSymbol = [piece.props objectForKey:@"OriginalSymbol"];
		
		if ( originalSymbol )
			[symbols appendString:originalSymbol];
		else
			[piece appendTo:symbols];
	}
	int				charsNum = [symbols length];
	unichar			*chars = calloc(charsNum, sizeof(unichar));
	[symbols getCharacters:chars];
	
	// get words set
	wordsSet = [wordValidator getValidWordSet:chars withCharsNum:charsNum withMinWordSize:minWordSize withMaxWordSize:maxWordSize andBlackList:blackList];
	
	// free stuff
	free(chars);
	
	return wordsSet;
}

-(NSString*)generateBoardWordSetRole
{
	return @"";
}

-(BOOL)includesRole:(NSString*)role
{
	return [[self role] isEqualToString:role];
}

-(id<GameBoardLogic>)getIncludedRole:(NSString*)role
{
	if ( [[self role] isEqualToString:role] )
		return self;
	else
		return nil;
}


@end
