//
//  BoardView.m
//  Board3
//
//  Created by Dror Kessler on 5/1/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "GridBoardView.h"
#import "BrandManager.h"

//#define	LOG_XY

@interface GridBoardView (Privates)
-(void)loadBrandProps;
@end


@implementation GridBoardView
@synthesize model = _model;
@synthesize cellWidth;
@synthesize cellHeight;
@synthesize cellMargin;

- (id)initWithFrame:(CGRect)frame andBoard:(GridBoard*)initBoard {
    if (self = [super initWithFrame:frame]) {

		self.model = initBoard;

		cellWidth = (frame.size.width - 1) / [_model width];
		cellHeight = (frame.size.height - 1) / [_model height];
		
		[self loadBrandProps];
		
		self.backgroundColor = [UIColor clearColor];
		
		[[BrandManager singleton] addDelegate:self];
	}
    return self;
}

-(void)dealloc
{
	[[BrandManager singleton] removeDelegate:self];
	
	[super dealloc];
}

- (void)drawRect:(CGRect)rect 
{
	Brand*			brand = [BrandManager currentBrand];
	CGContextRef	context = UIGraphicsGetCurrentContext();
	
	UIColor*		gridColor = [_model gridColor];
	if ( !gridColor )
		gridColor = [brand globalGridColor];
	
	CGContextSetStrokeColorWithColor(context, gridColor.CGColor);
	CGContextSetLineWidth(context, [brand globalGridLineWidth]);
	
	int				rows = [_model height];
	int				cols = [_model width];
	CGFloat			x1, y1, x2, y2;

	for ( int row = 0 ; row <= rows ; row++ )
	{
		CGContextMoveToPoint(context, x1 = 0.5, y1 = row * cellHeight + 0.5);
		CGContextAddLineToPoint(context, x2 = cols * cellWidth + 0.5, y2 = row * cellHeight + 0.5);
		CGContextStrokePath(context);
		
#ifdef	LOG_XY
		NSLog(@"[GridBoardView drawRect: rows (%f,%f) (%f,%f)", x1, y1, x2, y2);
#endif
	}
	for ( int col = 0 ; col <= cols ; col++ )
	{
		CGContextMoveToPoint(context, x1 = col * cellWidth + 0.5, y1 = 0.5);
		CGContextAddLineToPoint(context, x2 = col * cellWidth + 0.5, y2 = rows * cellHeight + 0.5);
		CGContextStrokePath(context);

#ifdef	LOG_XY
		NSLog(@"[GridBoardView drawRect: cols (%f,%f) (%f,%f)", x1, y1, x2, y2);
#endif
	}
}


- (CGRect)cellRectAt:(int)x andY:(int)y
{
	CGRect			rect;
	rect.origin.x = x * cellWidth + cellMargin + 1.0;
	rect.origin.y = y * cellHeight + cellMargin + 1.0;
	rect.size.width = cellWidth - cellMargin * 2;
	rect.size.height = cellHeight - cellMargin * 2;

	return rect;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	//NSLog(@"GridBoardView: touchesBegan");
	
	if ( [touches count] == 1 )
	{
		id	t0 = [[touches allObjects] objectAtIndex:0];
		if ( [t0 isKindOfClass:[UITouch class]] )
		{
			UITouch*	touch = t0;
			CGPoint		location = [touch locationInView:self];
			int		x = location.x / self.cellWidth;
			int		y = location.y / self.cellHeight;
			
			//NSLog(@"x=%d, y=%d", x, y);
			
			Cell*		cell = [_model cellAt:x andY:y];
			if ( cell && [cell view] )
				[[cell view] touchesBegan:touches withEvent:event];
		}
	}
}

-(void)loadBrandProps
{
	cellMargin = [[BrandManager currentBrand] globalInteger:@"skin/props/cell-margin" withDefaultValue:4];
}

-(void)brandDidChange:(Brand*)brand
{
	[self loadBrandProps];
	[self setNeedsDisplay];
	
}

@end
