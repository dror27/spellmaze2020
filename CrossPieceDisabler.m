//
//  CrossPieceDisabler.m
//  Board3
//
//  Created by Dror Kessler on 5/26/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "CrossPieceDisabler.h"
#import "GameLevel.h"
#import "GridCell.h"
#import "Cell.h"
#import "NSMutableArray_Shuffle.h"
#import "NSArray_Random.h"

//#define	DUMP

#define		GENERATE_BOARD_WORDSET_LIMIT			1000000		// no limit

@interface CrossPieceDisabler(Privates)
-(void)crossReset;
-(void)crossActivate:(id<Piece>)piece;
-(void)crossPiece:(id<Piece>)piece;
-(void)crossCell:(Cell*)cell;
-(BOOL)onCross:(int)x andY:(int)y;
-(BOOL)onCross:(int)x andY:(int)y withCenterX:(int)cx andCenterY:(int)cy;
@end



@implementation CrossPieceDisabler
@synthesize type;
@synthesize highlight;
@synthesize progressive;

-(void)pieceSelected:(id<Piece>)piece
{
	// activate cross on selection of first word
	if ( [[[_board level] currentWordPieces] count] == 0 )
		[self crossActivate:piece];
	else if ( progressive )
		[self crossActivate:piece];
}

-(void)pieceDispensed:(id<Piece>)piece
{
	id<Piece>		leadingPiece = [piece.props objectForKey:@"LeadingPiece"];
	if ( leadingPiece )
	{
		int		leadingX = [[leadingPiece cell] x];
		int		leadingY = [[leadingPiece cell] y];
		int		index;
		
		// collect free cells on the cross
		NSMutableArray*		freeCrossCells = [NSMutableArray array];
		for ( Cell* cell in [_board allCells] )
			if ( !cell.piece )
			{
				if ( [self onCross:[cell x] andY:[cell y] withCenterX:leadingX andCenterY:leadingY] )
					[freeCrossCells addObject:cell];
			}
		if ( [freeCrossCells count] )
		{
			Cell*	randomCell = (Cell*)[freeCrossCells objectAtRandomIndex];
			[randomCell setPiece:piece];
		}
		else
		{
			index = [_board randomFreeCellIndex];
			[_board placePiece:piece at:index];
		}
	}

	// if active, disable if outside cross
	if ( active )
		[self crossPiece:piece]; 
}

-(void)validWordSelected:(NSString*)word
{
	[self crossReset];
}

-(void)invalidWordSelected:(NSString*)word
{
	[self crossReset];
}

-(void)wordSelectionCanceled
{
	[self crossReset];
}

-(void)crossActivate:(id<Piece>)piece
{
	id<GridCell>	cell = [piece cell];
	
	// remember center
	centerX = [cell x];
	centerY = [cell y];
	
	// disable all pieces not on the cross (if already active, do not disable new pieces)
	for ( id<Piece> p1 in [_board allPieces] )
		if ( !active )
			[self crossPiece:p1];
		else if ( [p1 disabled] )
			[self crossPiece:p1];
			
	
	// highlight all cells on the cross
	if ( highlight )
		for ( Cell* cell in [_board allCells] )
			if ( !active )
				[self crossCell:cell];
			else if ( ![cell highlight] )
				[self crossCell:cell];

	active = TRUE;
}

-(void)crossPiece:(id<Piece>)piece
{
	id<GridCell>	cell = [piece cell];
	
	if ( ![self onCross:[cell x] andY:[cell y]] )
		[piece setDisabled:TRUE];
	else
		[piece setDisabled:FALSE];
}

-(void)crossCell:(Cell*)cell
{
	if ( [self onCross:[cell x] andY:[cell y]] )
		[cell setHighlight:TRUE];
	else 
		[cell setHighlight:FALSE];

}

-(void)crossReset
{
	if ( active )
	{
		// enable all pieces
		active = FALSE;
		for ( id<Piece> piece in [_board allPieces] )
			[piece setDisabled:FALSE];
		
		// unhighlight the board
		if ( highlight )
			for ( Cell* cell in [_board allCells] )
				[cell setHighlight:FALSE];
	}
}

-(BOOL)onCross:(int)x andY:(int)y
{
	return [self onCross:x andY:y withCenterX:centerX andCenterY:centerY];
}


-(BOOL)onCross:(int)x andY:(int)y withCenterX:(int)cx andCenterY:(int)cy
{
	switch ( type )
	{
		case CROSS :
			return (x == cx || y == cy);
		case DIAGONAL :
			return abs(x - cx) == abs(y - cy);
		case HORIZONTAL :
			return (y == cy);
		case VERTICAL :
			return (x == cx);
		case ADJACENT :
			return (abs(x - cx) <= 1) && (abs(y - cy) <= 1);
		default :
			return FALSE;
	}	
}

-(NSString*)role
{
	return @"Disable!";
}

-(CSetWrapper*)generateBoardWordSet:(NSMutableArray**)piecesOutput forBoard:(id<Board>)board withWordValidator:(id<WordValidator>)wordValidator withMinWordSize:(int)minWordSize andMaxWordSize:(int)maxWordSize andBlackList:(CSetWrapper*)blackList
{
	CSetWrapper*		result = [[[CSetWrapper alloc] init] autorelease];
	int					limit = GENERATE_BOARD_WORDSET_LIMIT;

	id<Piece>			lastLeadingPiece = NULL;
	
	// get pieces on the board
	NSMutableArray		*pieces = [[[NSMutableArray alloc] initWithArray:[board allPieces]] autorelease];
	
	// prepare vector of sets
	int					piecesNum = [pieces count];
	if ( piecesNum )
	{
		CSet**				piecesWords = alloca(sizeof(CSet*) * piecesNum);
	
		// for each piece, generate wordset which represents words that begin with this piece
		// ... and that the rest of the letters on these words reside on the "cross".
		// ... this simple mechnism ignores the 'progressive' feature
		int					piecesIndex = 0;
		NSMutableArray*		shuffledPieces = [NSMutableArray arrayWithArray:pieces];
		[shuffledPieces shuffle];
		
		for ( id<Piece> leadingPiece in shuffledPieces )
		{
			lastLeadingPiece = leadingPiece;
			
			NSMutableString*	leadingSymbols = [NSMutableString string];
			[leadingPiece appendTo:leadingSymbols];
			unichar				leadingCh0 = [leadingSymbols characterAtIndex:0];
			
			// collect pieces on the cross
			NSArray*	crossPieces = [self collectCrossPieces:leadingPiece fromPieces:pieces];
		
			// extract symbols
			NSMutableString *symbols = [[[NSMutableString alloc] init] autorelease];
			for ( id<Piece> piece in crossPieces )
				[piece appendTo:symbols];
			int				charsNum = [symbols length];
			unichar			*chars = alloca(charsNum * sizeof(unichar));
			[symbols getCharacters:chars];
		
			// get words set
			CSetWrapper		*wordsSet = [wordValidator getValidWordSet:chars withCharsNum:charsNum withMinWordSize:minWordSize withMaxWordSize:maxWordSize andBlackList:blackList];		
			piecesWords[piecesIndex++] = wordsSet.cs;
			
			// must manually remove all words which do not begin with the leading character ... 
			// TODO: this is rather expensive ... find an alternative way ...
			CSet*			cs = wordsSet.cs;
			CSet_SortElements(cs);
			T_ELEM*		src = cs->elems;
			T_ELEM*		dst = cs->elems;
			T_ELEM*		end = cs->elems + cs->size;
			int			elemsRemoved = 0;
	
			while ( src < end )
			{
				T_ELEM		elem = *src;
				unichar		ch0 = [wordValidator getValidWordCharacterByIndex:elem characterAt:0];
				if ( ch0 == leadingCh0 )
					*dst++ = *src++;
				else
				{
					src++;
					elemsRemoved++;
				}
			}
			cs->size -= elemsRemoved;
			
#ifdef DUMP
			{
				NSMutableString*	s = [NSMutableString string];
				[leadingPiece appendTo:s];
				
				NSLog(@"[CrossPieceDisabler] : leadingPiece = '%@' (%d,%d)", s, [[leadingPiece cell] x], [[leadingPiece cell] y]);
				CSet*				cs = wordsSet.cs;
				for ( int n = 0 ; n < cs->size ; n++ )
					NSLog(@"-- %@", [wordValidator getValidWordByIndex:cs->elems[n]]);
			}
#endif
			
			limit -= cs->size;
			if ( limit <= 0 )
				break;
		}
	
		// union all individual sets into the result
		CSet_Union(piecesWords, piecesIndex, result.cs);
	}
	
#ifdef DUMP
	{
		NSLog(@"[CrossPieceDisabler] : result");
		CSet*				cs = result.cs;
		for ( int n = 0 ; n < cs->size ; n++ )
			NSLog(@"-- %@", [wordValidator getValidWordByIndex:cs->elems[n]]);
	}
#endif
	
	if ( piecesOutput )
	{
		if ( !lastLeadingPiece )
			*piecesOutput = pieces;
		else
		{
			// make sure that the last leading piece is the first piece
			NSMutableArray*		newPieces = [NSMutableArray arrayWithObject:lastLeadingPiece];
			for ( id<Piece> piece in pieces )
				if ( piece != lastLeadingPiece )
					[newPieces addObject:piece];
			
			*piecesOutput = newPieces;
		}
	}
	
	return result;
}

-(NSArray*)collectCrossPieces:(id<Piece>)leadingPiece fromPieces:(NSArray*)pieces
{
	// leading piece always in
	NSMutableArray*		result = [NSMutableArray arrayWithObject:leadingPiece];

	// establish center
	Cell*				leadingCell = [leadingPiece cell];
	int					cx = [leadingCell x];
	int					cy = [leadingCell y];
	
	// loop on pieces
	for ( id<Piece> piece in pieces )
		if ( piece != leadingPiece )
		{
			Cell*			cell = [piece cell];
			int				x = [cell x];
			int				y = [cell y];
			
			if ( [self onCross:x andY:y withCenterX:cx andCenterY:cy] )
				[result addObject:piece];
		}
	
	return result;
}

-(NSString*)generateBoardWordSetRole
{
	return [self role];
}

@end
