//
//  CellView.m
//  Board3
//
//  Created by Dror Kessler on 5/8/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "CellView.h"
#import "Cell.h"


@implementation CellView
@synthesize model = _model;

static UIColor*		normalColor;
static UIColor*		highlightColor;

+(void)initialize
{
	[super initialize];
	
	normalColor = [UIColor blackColor];
	
	// TODO: replace with a pattern ... of diagonal lines maybe ...
	highlightColor = [[UIColor alloc] initWithRed:0.3 green:1.0 blue:0.3 alpha:1]; 
}

-(id)initWithFrame:(CGRect)frame andCell:(Cell*)initCell {
    if (self = [super initWithFrame:frame]) 
	{
		self.model = initCell;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(BOOL)highlight
{
	return highlight;
}

-(void)setHighlight:(BOOL)newHighlight
{
	if ( highlight != newHighlight )
	{
		highlight = newHighlight;

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.backgroundColor = highlight ? highlightColor : normalColor;
		[UIView commitAnimations];	
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	id<Piece>	piece = [_model piece];
	if ( piece && [piece view] )
		[[piece view] touchesBegan:touches withEvent:event];
}



- (void)dealloc {
    [super dealloc];
}



@end
