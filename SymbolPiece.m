//
//  SymbolPiece.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "SymbolPiece.h"
#import "SymbolPieceView.h"

#import "GameLevel.h"
#import "PieceDecorator.h"

@implementation SymbolPiece

@synthesize text = _text;
@synthesize image = _image;
@synthesize view = _view;
@synthesize cell = _d_cell;
@synthesize isSelected;
@synthesize props = _props;
@synthesize decorators = _decorators;
@synthesize showSymbolText;

-(void)dealloc
{
	for ( id<PieceDecorator> dec in [_decorators allValues] )
		[dec undecorate];
	
	[_text release];
	[_image release];
	
	[_view setModel:nil];
	[_view release];
	
	[_props release];
	[_decorators release];
	
	[super dealloc];
}

-(id)init
{
	if ( self = [super init] )
	{
		isSelected = FALSE;
		self.props = [[[NSMutableDictionary alloc] init] autorelease];
		self.decorators = [[[NSMutableDictionary alloc] init] autorelease];
		showSymbolText = FALSE;
	}
	return self;
}

-(UIView*)viewWithFrame:(CGRect)frame
{
	if ( !_view )
	{
		viewSize = frame.size;
		self.view = [[[SymbolPieceView alloc] initWithFrame:frame andModel:self] autorelease];
		_view.lastScreenSize = frame.size;
		
	} 
#ifdef	ADVANCED_SCALING
	
	else if ( CGSizeEqualToSize(frame.size, viewSize) )
		;
	else
	{
		SymbolPieceView*	lastView = _view;
		self.view = [[[SymbolPieceView alloc] initWithFrame:frame andModel:self] autorelease];
		_view.lastScreenX = lastView.lastScreenX;
		_view.lastScreenY = lastView.lastScreenY;
		_view.lastScreenSize = viewSize;
		viewSize = frame.size;
		[lastView removeFromSuperview];
	}
#endif
	
	return _view;
}

-(void)clicked
{
	if ( [[_d_cell board] piecesSelectable] )
	{
		if ( !isSelected )
		{
			[self select];
			[[self eventsTarget] pieceSelected:self];		
		}
		else
		{
			[[self eventsTarget] pieceReselected:self];
		}
	}
	else
		[[self eventsTarget] pieceClicked:self];
}

-(void)disabledClicked
{
	if ( [_d_eventsTarget respondsToSelector:@selector(disabledPieceClicked:)] )
		[_d_eventsTarget disabledPieceClicked:self];
}

-(void)select
{
	if ( !isSelected )
	{
		isSelected = TRUE;
		[_view updateSelected:isSelected];		
	}
}

-(void)deselect
{
	if ( isSelected )
	{
		isSelected = FALSE;
		[_view updateSelected:isSelected];		
	}	
}

-(void)hinted:(BOOL)last
{
	[_view hinted:last];
}

-(void)reset
{
	if ( isSelected )
	{
		isSelected = FALSE;
		[_view updateSelected:isSelected];
	}
}

-(void)eliminate
{
	// disconnect
	[_d_cell abandonPiece];
	self.cell = NULL;
	
	// allow view to eliminate
	[_view eliminate];
}

-(void)examine
{
	[_view examine];
}

-(float)fade
{
	return [_view fade];
}

-(void)setFade:(float)fade
{
	[_view setFade:fade];
}

-(BOOL)disabled
{
	return [_view disabled];
}

-(void)setDisabled:(BOOL)newDisabled
{
	[_view setDisabled:newDisabled];
}

-(BOOL)hidden
{
	return [_view hidden];
}

-(void)setHidden:(BOOL)newHidden
{
	[_view setHidden:newHidden];
}

-(void)appendTo:(NSMutableString*)s
{	
	[s appendString:_text];
}

-(id<PieceEventsTarget>)eventsTarget
{
	return _d_eventsTarget ? _d_eventsTarget : [[[self cell] board] level];
}

-(void)setEventsTarget:(id<PieceEventsTarget>)newEventsTarget
{
	[_d_eventsTarget autorelease];
	_d_eventsTarget = [newEventsTarget retain];
}

-(unichar)symbol
{
	return (_text && [_text length]) ? [_text characterAtIndex:0] : '\0';
}

-(void)setSymbol:(unichar)symbol
{
	self.text = [NSString stringWithCharacters:&symbol length:1];
	if ( _view )
		[_view updateText];
}

-(void)setText:(NSString*)text
{
	[_text autorelease];
	_text = [text retain];
	if ( _view )
		[_view updateText];
}

-(void)setImage:(UIImage*)image
{
	[_image autorelease];
	_image = [image retain];
	if ( _view )
		[_view updateText];
}	

-(void)addDecorator:(NSString*)decoratorName
{
	id<PieceDecorator>		dec = [_decorators objectForKey:decoratorName];

	if ( !dec )
	{
		dec = [[[[[NSBundle mainBundle] classNamed:decoratorName] alloc] init] autorelease];
		
		[dec decorate:self];
		[_decorators setObject:dec forKey:decoratorName];
	}
}

-(void)removeDecorator:(NSString*)decoratorName
{
	id<PieceDecorator>		dec = [_decorators objectForKey:decoratorName];
	
	if ( dec )
	{
		[dec undecorate];
		[_decorators removeObjectForKey:decoratorName];
	}
}

-(BOOL)hasDecorator:(NSString*)decoratorName
{
	if ( decoratorName )
		return [_decorators objectForKey:decoratorName] != NULL;
	else
		return [_decorators count] != 0;
}

-(BOOL)selected
{
	return isSelected;
}

-(BOOL)sameContentAs:(id<Piece>)piece
{
	if ( ![piece isKindOfClass:[SymbolPiece class]] )
		return FALSE;
	
	SymbolPiece*	p = (SymbolPiece*)piece;
	
	return [p.text isEqualToString:self.text];
}

@end
