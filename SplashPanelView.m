//
//  SplashPanelView.m
//  Board3
//
//  Created by Dror Kessler on 9/2/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "SplashPanelView.h"
#import "SplashPanel.h"
#import "BrandManager.h"
#import "ImageSequenceMediaView.h"
#import "UIImage_ResizeImageAllocator.h"
#import "RTLUtils.h"
#import "L.h"
#import "ViewController.h"

#define		TOP_PORTION		0.12
#define		BOTTOM_PORTION	0.12

#define		TOP_MARGIN		10
#define		BOTTOM_MARGIN	40


@implementation SplashPanelView
@synthesize model = _model;

-(id)initWithFrame:(CGRect)frame andModel:(SplashPanel*)model
{
	if ( self = [super initWithFrame:frame] )
	{
		Brand*		brand = [BrandManager currentBrand];
		
		self.model = model;
	
		// global view stuff
		self.backgroundColor = [brand globalColor:@"splash-background" withDefaultValue:[UIColor colorWithWhite:0 alpha:1.0]];
		
		// title
		topAllocation = model.height * TOP_PORTION;
		CGRect		titleFrame = CGRectMake(0, 0, model.width, topAllocation);
		UILabel*	title = [[[UILabel alloc] initWithFrame:titleFrame] autorelease];
		title.text = RTL(model.title);
		title.backgroundColor = [UIColor clearColor];
		title.font = [brand globalDefaultFont:AW(16) bold:TRUE];
		title.textColor = [brand globalTextColor];
		title.textAlignment = NSTextAlignmentCenter;
		title.adjustsFontSizeToFitWidth = TRUE;
		[self addSubview:title];
		

		// get icon, consult brand
		UIImage*	icon = model.icon;
		if ( !icon )
			icon = [brand globalImage:@"character" withDefaultValue:NULL];
		
		// instructions or icon
		if ( !icon )
		{
			bottomAllocation = model.height * BOTTOM_PORTION;
			CGRect		instructionsFrame = CGRectMake(0, model.height - bottomAllocation, model.width, bottomAllocation);
			UILabel*	instructions = [[[UILabel alloc] initWithFrame:instructionsFrame] autorelease];
			instructions.text = LOC(@"Tap to Continue ..."); 
			instructions.backgroundColor = [UIColor clearColor];
			instructions.font = [brand globalDefaultFont:AW(12) bold:TRUE];
			instructions.textColor = [brand globalTextColor];
			instructions.textAlignment = NSTextAlignmentCenter;
			[self addSubview:instructions];
		}
		else
		{
			if ( MAX(icon.size.width, icon.size.height) > 150 )
			{	
				icon = [icon scaleImageToSize:CGSizeMake(150,150)];
			}
			
			int			margin = 12;
			bottomAllocation = icon.size.height + margin;
			CGRect		iconFrame = CGRectMake((model.width - icon.size.width) / 2.0, model.height - bottomAllocation + margin / 2.0, icon.size.width, icon.size.height);
			UIImageView* iconView = [[[UIImageView alloc] initWithFrame:iconFrame] autorelease];
			iconView.image = icon;
			[self addSubview:iconView];
		}
		
		// fit text remining space
		float		textMargin = 6;
		float		textY = topAllocation + textMargin;
		float		textHeight = model.height - bottomAllocation - topAllocation - 2 * textMargin;
		CGRect		textFrame = CGRectMake(textMargin, textY, model.width - 2 * textMargin, textHeight);

		UITextView*	text = [[[UITextView alloc] initWithFrame:textFrame] autorelease];
		text.backgroundColor = [UIColor clearColor];
		text.textColor = [brand globalTextColor];
		if ( model.textFontSize )
			text.font = [brand globalDefaultFont:model.textFontSize bold:FALSE];
		else
			text.font = [brand globalDefaultFont:AW(14) bold:FALSE];
		text.text = RTL(model.text);
		text.textAlignment = NSTextAlignmentCenter;
		text.editable = FALSE;
		text.userInteractionEnabled = FALSE;
		[self addSubview:text];
	}
	return self;
}
							  

- (void)drawRect:(CGRect)rect 
{
	Brand*		brand = [BrandManager currentBrand];
	float		width = self.model.width;
	float		height = self.model.height;

	
	CGContextRef	context = UIGraphicsGetCurrentContext();
	

	// border
	CGContextSetStrokeColorWithColor(context, [brand globalGridColor].CGColor);
	CGContextSetLineWidth(context, 4.0);
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, width, 0);
	CGContextAddLineToPoint(context, width, height);
	CGContextAddLineToPoint(context, 0, height);	
	CGContextAddLineToPoint(context, 0, 0);	
	CGContextStrokePath(context);
	
	// top seperator
	CGContextSetStrokeColorWithColor(context, [brand globalGridColor].CGColor);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, TOP_MARGIN, topAllocation);
	CGContextAddLineToPoint(context, width - TOP_MARGIN, topAllocation);
	CGContextStrokePath(context);

	// bottom seperator
#if 0
	CGContextSetStrokeColorWithColor(context, [brand globalGridColor].CGColor);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, BOTTOM_MARGIN, height - bottomAllocation);
	CGContextAddLineToPoint(context, width - BOTTOM_MARGIN, height - bottomAllocation);
	CGContextStrokePath(context);
#endif
	
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self.model onTouched];
}

@end
