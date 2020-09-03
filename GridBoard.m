//
//  Board.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoard.h"
#import	"GridBoardView.h"

@interface GridBoard (Privates)
-(Cell*)initCellAt:(int)x andY:(int)y;
-(Cell*)initCellAt:(int)index;
-(BOOL)isCellEmpty:(Cell*)cell;
@end


@implementation GridBoard

@synthesize width;
@synthesize height;
@synthesize view = _view;
@synthesize level = _level;
@synthesize piecesSelectable;
@synthesize gridColor = _gridColor;
@synthesize suggestedFrame;

-(id)initWithWidth:(int)initWidth andHeight:(int)initHeight
{
	if ( self = [super init] )
	{
		width = initWidth;
		height = initHeight;
		_cells = (Cell**)calloc(height * width, sizeof(Cell*));
		piecesSelectable = TRUE;
	}
	return self;
}

-(void)dealloc
{
	[_view setModel:nil];
	[_view release];
	
	for ( int index = 0 ; index < height * width ; index++ )
	{
		if ( _cells[index] )
		{
			[_cells[index] setBoard:nil];
			[_cells[index] release];
		}
	}
	free(_cells);
	
	[_gridColor release];

	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( !_view )
		self.view = [[[GridBoardView alloc] initWithFrame:frame andBoard:self] autorelease];
	
	return _view;
}

-(Cell*)cellAt:(int)index
{
	index %= (width * height);

	return _cells[index];
}

-(Cell*)cellAt:(int)x andY:(int)y
{
	x %= width;
	y %= height;
	
	return _cells[y*width+x];
}

-(int)cellCount
{
	return width * height;
}

-(int)freeCellCount
{
	int		count = 0;
	
	for ( int index = 0 ; index < height * width ; index++ )
		if ( [self isCellEmpty:_cells[index]] )
			count++;
	
	//printf("board: freeCellCount=%d\n", count);
	
	return count;
}

-(id<Piece>)pieceAt:(int)index
{
	index %= (width * height);

	Cell*		cell = _cells[index];

	return cell ? [cell piece] : NULL;
}

-(id<Piece>)pieceAt:(int)x andY:(int)y
{
	x %= width;
	y %= height;

	return [self pieceAt:y*width+x];
}

-(id<Piece>)placePiece:(id<Piece>)piece at:(int)index
{
	index %= (width * height);
	
	id<Piece>	oldPiece = NULL;
	Cell*		cell = _cells[index];
	
	if ( cell == NULL )
		cell = [self initCellAt:index];
	
	oldPiece = [cell piece];
	[cell setPiece:piece];
	
	return oldPiece;
}

-(id<Piece>)placePiece:(id<Piece>)piece at:(int)x andY:(int)y
{
	x %= width;
	y %= height;
	
	return [self placePiece:piece at:y*width+x];
}

-(int)randomFreeCellIndex
{
	int			count = [self freeCellCount];
	int			randIndex = rand() % count;
	Cell*		cell;
	
	for ( int index = 0 ; index < width*height ; index++ )
	{
		cell = _cells[index];
		if ( !randIndex && [self isCellEmpty:cell] )
			return index;
		
		if ( [self isCellEmpty:cell] )
			randIndex--;
	}
	
	return -1;
}

-(CGPoint)randomFreeCellCoor
{
	int			index = [self randomFreeCellIndex];
	CGPoint		coor = {-1,-1};

	if ( index >= 0 )
	{
		coor.x = index % width;
		coor.y = index / width;
	}
	
	return coor;
}

-(BOOL)isCellEmpty:(Cell*)cell
{
	return !cell || ![cell piece];
}

-(BOOL)isEmpty
{
	return [self cellCount] == [self freeCellCount];
}

-(NSArray*)allPieces
{
	NSMutableArray*		result = [[[NSMutableArray alloc] init] autorelease];
	
	for ( int index = 0 ; index < height * width ; index++ )
	{
		Cell*		cell = _cells[index];
		
		if ( cell )
		{
			id<Piece>		piece = [cell piece];
			
			if ( piece )
				[result addObject:piece];
		}
	}
	
	return result;
}

-(NSArray*)allCells
{
	NSMutableArray*		result = [[[NSMutableArray alloc] init] autorelease];
	
	for ( int index = 0 ; index < height * width ; index++ )
	{
		Cell*		cell = _cells[index];
		int			x = index % width;
		int			y = index / width;
		
		if ( !cell )
			cell = [self initCellAt:x andY:y];

		[result addObject:cell];
	}
	
	return result;
}

-(Cell*)initCellAt:(int)index
{
	index %= (width * height);

	Cell*	cell = [[[Cell alloc] init] autorelease];
	
	[cell setBoard:self];
	cell.x = index % width;
	cell.y = index / width;
	[_view addSubview:[cell viewWithFrame:[_view cellRectAt:cell.x andY:cell.y]]];
	
	[_cells[index] autorelease];
	_cells[index] = [cell retain];
	
	return cell;
}

-(Cell*)initCellAt:(int)x andY:(int)y
{
	return [self initCellAt:y*width+x];
}

@end
