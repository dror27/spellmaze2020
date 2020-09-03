//
//  GridBoardPieceDispenserWords.m
//  Board3
//
//  Created by Dror Kessler on 5/13/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoardPieceDispenserWords.h"
#import "SymbolPiece.h"
#import	"PieceDispensingHintsImpl.h"

@implementation GridBoardPieceDispenserWords
@synthesize wordDispenser = _wordDispenser;
@synthesize currentWord = _currentWord;
@synthesize interWordTickPeriod;
@synthesize scrambleWordSymbols;

static int wordId = 0;

-(void)dealloc
{
	[_wordDispenser release];
	[_currentWord release];
	
	if ( _dispensingOrder )
		free(_dispensingOrder);

	[super dealloc];
}

-(BOOL)preparePiece
{
	if ( _currentWord != NULL || [_wordDispenser canDispense] )
	{
		// get next word?
		if ( _currentWord == NULL )
		{
			self.currentWord = [_wordDispenser dispense];
			currentWordId = ++wordId;
			[self buildDispensingOrder];
			currentIndex = 0;
		}
		if ( _currentWord == NULL )
			return FALSE;
		
		// setup hints
		PieceDispensingHintsImpl*	hints = [[[PieceDispensingHintsImpl alloc] init] autorelease];
		[hints addStringHint:@"Word" withValue:_currentWord];
		[hints addIntHint:@"WordId" withValue:currentWordId];
		[hints addIntHint:@"WordSize" withValue:[_currentWord length]];
		[hints addIntHint:@"WordDispensingIndex" withValue:currentIndex];
		[hints addIntHint:@"WordSymbolIndex" withValue:_dispensingOrder[currentIndex]];
		[hints addIntHint:@"WordIsLast" withValue:![_wordDispenser canDispense]];
		
		// get next symbol
		unichar			symbol = [_currentWord characterAtIndex:_dispensingOrder[currentIndex]];
		if ( ++currentIndex >= [_currentWord length] )
			self.currentWord = NULL;
		
		if ( symbol != ' ' )
		{
			// build piece
			SymbolPiece*	piece = [self piece:symbol withImage:NULL];
			[[piece props] setObject:hints forKey:@"hints"];
			[_ownBoard placePiece:piece at:0];
		}
		else
			return [self preparePiece];
		
		return TRUE;
	}
	else
		return FALSE;
}

-(float)progress
{
	return [_wordDispenser progress];
}

-(float)nextTickPeriod
{
	return currentIndex == 1 ? interWordTickPeriod : [super nextTickPeriod];
}

-(void)buildDispensingOrder
{
	int		size = [_currentWord length];
	
	// allocate
	if ( _dispensingOrder )
		free(_dispensingOrder);
	_dispensingOrder = calloc(size, sizeof(int));

	// fill with normal order
	for ( int n = 0 ; n < size ; n++ )
		_dispensingOrder[n] = n;
	
	// scramble?
	if ( [self scrambleWordSymbols] )
	{
		for ( int trys = 0 ; trys < 5 ; trys++ )
		{
			// scramble through swapping ... primitive ...
			for ( int n = 0 ; n < size * 2 ; n++ )
			{
				int		i1 = rand() % size;
				int		i2 = rand() % size;
				
				int		tmp = _dispensingOrder[i1];
				_dispensingOrder[i1] = _dispensingOrder[i2];
				_dispensingOrder[i2] = tmp;
			}
			
			// check if scambled indeed
			int		inPlaceCount = 0;
			for ( int n = 0 ; n < size ; n++ )
				if ( _dispensingOrder[n] == n )
					inPlaceCount++;
			if ( inPlaceCount != size )
				break;
		}
	}
}

-(NSString*)scramble:(NSString*)word
{
	NSMutableString*	in = [[NSMutableString alloc] initWithString:word];
	NSMutableString*	out = [[NSMutableString alloc] init];
	
	while ( [in length] )
	{
		int		index = rand() % [in length];
		unichar	ch = [in characterAtIndex:index];
		
		NSRange	range = {index,1};
		[out appendString:[[NSString alloc] initWithCharacters:&ch length:1]];
		[in deleteCharactersInRange:range];
	}
	
	return out;
}

-(void)setBoard:(GridBoard*)board
{
	if ( [_wordDispenser respondsToSelector:@selector(setBoard:)] )
		[_wordDispenser performSelector:@selector(setBoard:) withObject:board];
}


@end
