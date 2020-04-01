//
//  Cell.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "Cell.h"
#import "CellView.h"
#import "PieceView.h"

@implementation Cell
@synthesize view = _view;
@synthesize board = _board;
@synthesize x;
@synthesize y;

-(void)dealloc
{
	[_view setModel:nil];
	[_view release];
	
	[_piece setCell:nil];
	[_piece release];
	
	[super dealloc];
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( !_view )
		self.view = [[[CellView alloc] initWithFrame:frame andCell:self] autorelease];
	
	return _view;
}

-(id<Piece>)piece
{
	return _piece;
}

-(void)setPiece:(id<Piece>)newPiece
{
	if ( _piece != NULL )
	{
		[_piece setCell:nil];
		[[_piece view] removeFromSuperview];
		[_piece autorelease];
		_piece = NULL;
	}
	
	if ( newPiece )
	{
		_piece = [newPiece retain];
		[_piece setCell:self];
	
		CGRect	frame = [_view frame];
		frame.origin.x = 0;
		frame.origin.y = 0;
		UIView<PieceView> *pieceView = [_piece viewWithFrame:frame]; 
		[_view addSubview:pieceView];
		
		[pieceView placed];		
	}
}

-(BOOL)highlight
{
	return [_view highlight];
}

-(void)setHighlight:(BOOL)newHighlight
{
	[_view setHighlight:newHighlight];
}

-(void)abandonPiece
{
	[_piece autorelease];
	_piece = NULL;
}
@end
