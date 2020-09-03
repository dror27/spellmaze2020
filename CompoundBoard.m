//
//  CompoundBoard.m
//  Board3
//
//  Created by Dror Kessler on 6/9/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import <objc/runtime.h>
#import "CompoundBoard.h"
#import "GameLevel.h"
#import "FormulaEvaluator.h"
#import "TextBlockSplitter.h"
#import "GridBoard.h"
#import "ViewController.h"

@interface CompoundBoardElement : NSObject
{
	id<Board>		_board;
	CGRect			frame;
	int				size;
}
@property (retain) id<Board> board;
@property CGRect frame;
@property int size;
@end

@implementation CompoundBoardElement
@synthesize board = _board;
@synthesize frame;
@synthesize size;

-(void)dealloc
{
	[_board release];
	
	[super dealloc];
}

@end

@interface CompoundBoard (Privates)
+(id<Board>)boardByComponent:(NSString*)boardComponent outputFrame:(CGRect*)outputFrame;
+(UIColor*)colorBySpec:(NSString*)spec;
@end


@implementation CompoundBoard
@synthesize boards = _boards;
@synthesize view = _view;
@synthesize level = _level;
@synthesize suggestedFrame;


-(id)init
{
	if ( self = [super init] )
	{
		self.boards = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[_boards release];
	[_view release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( !_view )
	{
		self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
		
		for ( CompoundBoardElement* elem in _boards )
			[_view addSubview:[elem.board viewWithFrame:elem.frame]];
	}
	
	return _view;
}

-(void)addBoard:(id<Board>)board withFrame:(CGRect)frame
{
	CompoundBoardElement*	elem = [[[CompoundBoardElement alloc] init] autorelease];
	
	elem.board = board;
	elem.frame = frame;
	elem.size = [board cellCount];
	
	[_boards addObject:elem];
}

-(void)addBoard:(id<Board>)board withX:(int)x andY:(int)y andWidth:(int)width andHeight:(int)height;
{
	CGRect		frame = {{x,y}, {width,height}};
	
	[self addBoard:board withFrame:frame];
}

-(int)cellCount
{
	int		count = 0;
	
	for ( CompoundBoardElement* elem in _boards )
		count += elem.size;
	
	return count;
}

-(int)freeCellCount
{
	int		count = 0;
	
	for ( CompoundBoardElement* elem in _boards )
		count += [elem.board freeCellCount];
	
	return count;	
}

-(BOOL)isEmpty
{
	for ( CompoundBoardElement* elem in _boards )
		if ( ![elem.board isEmpty] )
			return FALSE;
	
	return TRUE;
}

-(Cell*)cellAt:(int)index
{
	for ( CompoundBoardElement* elem in _boards )
		if ( index < elem.size )
			return [elem.board cellAt:index];
		else
			index -= elem.size;
	
	return NULL;
}

-(NSArray*)allCells
{
	NSMutableArray*		all = [[[NSMutableArray alloc] init] autorelease];
	
	for ( CompoundBoardElement* elem in _boards )
		[all addObjectsFromArray:[elem.board allCells]];
	
	return all;
}

-(id<Piece>)pieceAt:(int)index
{
	for ( CompoundBoardElement* elem in _boards )
		if ( index < elem.size )
			return [elem.board pieceAt:index];
		else
			index -= elem.size;
	
	return NULL;
}

-(NSArray*)allPieces
{
	NSMutableArray*		all = [[[NSMutableArray alloc] init] autorelease];
	
	for ( CompoundBoardElement* elem in _boards )
		[all addObjectsFromArray:[elem.board allPieces]];
	
	return all;	
}

-(id<Piece>)placePiece:(id<Piece>)piece at:(int)index
{
	for ( CompoundBoardElement* elem in _boards )
		if ( index < elem.size )
			return [elem.board placePiece:piece at:index];
		else
			index -= elem.size;
	
	return NULL;	
}

-(int)randomFreeCellIndex
{
	int			count = [_boards count];
	int			ofs = rand() % count;
	
	for ( int boardIndex = 0 ; boardIndex < count ; boardIndex++ )
	{
		int							boardIndex1 = ((boardIndex + ofs) % count);
		CompoundBoardElement*		elem = [_boards objectAtIndex:boardIndex1];
		
		if ( [elem.board freeCellCount] > 0 )
		{
			int		ofs1 = 0;
			for ( CompoundBoardElement* elem1 in _boards )
				if ( boardIndex1-- )
					ofs1 += [elem1 size];
				else
					break;

			return ofs1 + [elem.board randomFreeCellIndex];
		}
	}
	
	return -1;
}

-(BOOL)piecesSelectable
{
	if ( [_boards count] == 0 )
		return FALSE;
	else
	{
		CompoundBoardElement*	elem = [_boards objectAtIndex:0];
		
		return [elem.board piecesSelectable];
	}
}

-(void)setPiecesSelectable:(BOOL)piecesSelectable
{
	if ( [_boards count] == 0 )
		return;
	else
	{
		CompoundBoardElement*	elem = [_boards objectAtIndex:0];
		
		[elem.board setPiecesSelectable:piecesSelectable];
	}
}


-(GameLevel*)level
{
	return _level;
}

-(void)setLevel:(GameLevel*)newLevel
{
	_level = newLevel;
	
	for ( CompoundBoardElement* elem in _boards )
		[elem.board setLevel:newLevel];
}

+(id<Board>)boardByFormula:(NSString*)boardFormula
{
	//NSLog(@"[CompoundBoard] boardFormula: %@", boardFormula);
	
	// get component specifications create default board if no spec
	NSArray*		comps = [[TextBlockSplitter splitter] split:[[FormulaEvaluator evaluator] evalToString:boardFormula]];
	//NSLog(@"[CompoundBoard] comps: %@", comps);	
	if ( !comps || ![comps count] )
		return [[[GridBoard alloc] initWithWidth:6 andHeight:6] autorelease];
	
	
	// if only one component, generate a board directly from it
	if ( [comps count] == 1 )
		return [CompoundBoard boardByComponent:[comps objectAtIndex:0] outputFrame:NULL];
	
	// build compound board
	CompoundBoard*	board = [[[CompoundBoard alloc] init] autorelease];
	for ( NSString* comp in comps )
	{
		CGRect		frame;
		id<Board>	subBoard = [CompoundBoard boardByComponent:comp outputFrame:&frame];
		
		[board addBoard:subBoard withFrame:frame];
	}
	return board;
}														

+(id<Board>)boardByComponent:(NSString*)boardComponent outputFrame:(CGRect*)outputFrame; 
{
	// comp: x y width height cols rows
	double			x = 0, y = 0;
    double			width = [ViewController adjWidth:60];
    double          height = width;
	int				rows = 6, cols = 6;
	UIColor*		gridColor = NULL;
	
	// read toks
	NSArray*		toks = [boardComponent componentsSeparatedByString:@" "];
	int				tokIndex = 0;
	for ( NSString* tok in toks )
	{
		switch ( tokIndex++ )
		{
			case 0 :
				x = [ViewController adjWidth:atof([tok UTF8String])];
				break;

			case 1 :
				y = [ViewController adjWidth:atof([tok UTF8String])];
				break;

			case 2 :
				width = [ViewController adjWidth:atof([tok UTF8String])];
				break;
				
			case 3 :
				height = [ViewController adjWidth:atof([tok UTF8String])];
				break;
				
			case 4 :
				cols = atoi([tok UTF8String]);
				break;
				
			case 5 :
				rows = atof([tok UTF8String]);
				break;

			case 6 :
				gridColor = [CompoundBoard colorBySpec:tok];
				break;				
		}
	}
	
	// scale (from 60 to 48)
	double		factor = 48.0 / 60.0;
	x *= factor;
	y *= factor;
	width *= factor;
	height *= factor;
	
	// build board
	GridBoard*		board = [[[GridBoard alloc] initWithWidth:cols andHeight:rows] autorelease];
	board.gridColor = gridColor;
	
	// build frame
	CGRect			frame;
	frame.origin.x = x;
	frame.origin.y = y;
	frame.size.width = round(width * cols + 1);
	frame.size.height = round(height * rows + 1);
	board.suggestedFrame = frame;
	
	// return frame?
	if ( outputFrame )
		*outputFrame = frame;
	
	return board;
}

+(UIColor*)colorBySpec:(NSString*)spec
{
	NSArray*	comps = [spec componentsSeparatedByString:@","];
	
	if ( [comps count] == 1 )
	{
		// by name
		SEL			selector = sel_getUid([[NSString stringWithFormat:@"%@Color", [comps objectAtIndex:0]] UTF8String]);
		
		return [[UIColor class] performSelector:selector];
	}
	else if ( [comps count] >= 3 )
	{
		double		r = atof([((NSString*)[comps objectAtIndex:0]) UTF8String]);
		double		g = atof([((NSString*)[comps objectAtIndex:1]) UTF8String]);
		double		b = atof([((NSString*)[comps objectAtIndex:2]) UTF8String]);
		double		a = 1.0;
		if ( [comps count] > 3 )
			a = atof([((NSString*)[comps objectAtIndex:3]) UTF8String]);
		
		return [UIColor colorWithRed:r green:g blue:b alpha:a];
	}
	else
		return [UIColor clearColor];
}
			
@end
