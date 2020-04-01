/*

File: LabelCell.m
Abstract: UITableView utility cell that describes where to find UIView code.

Version: 1.7

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "LabelCell.h"
#import "Constants.h"

// cell identifier for this custom cell
NSString *kLabelCell_ID = @"LabelCell_ID";

#define kCellHeight	25.0

@implementation LabelCell

@synthesize label;
@synthesize delegate;
@synthesize context;
@synthesize control = _control;

- (id)initWithFrame:(CGRect)aRect reuseIdentifier:(NSString *)identifier
{
	if (self = [super initWithFrame:aRect reuseIdentifier:identifier])
	{
		// turn off selection use
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		label = [[UILabel alloc] initWithFrame:aRect];
		label.backgroundColor = [UIColor clearColor];
		label.opaque = NO;
		label.textAlignment = UITextAlignmentLeft;
		label.textColor = [UIColor blackColor];
		label.font = [UIFont boldSystemFontOfSize:18];
		label.highlightedTextColor = [UIColor blackColor];
		label.lineBreakMode = UILineBreakModeMiddleTruncation;
		
		// details button
		details = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
		details.frame = CGRectMake(0, 0, 25.0, 25.0);
		[details setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		details.backgroundColor = [UIColor clearColor];
		[details addTarget:self action:@selector(doDetail:) forControlEvents:UIControlEventTouchUpInside];
		details.alpha = 0.0;		// initially hidden
		
		[self.contentView addSubview:label];
		[self.contentView addSubview:details];
	}
	return self;
}

-(void)setControl:(UIView*)control
{
	[_control removeFromSuperview];
	[_control autorelease];
	_control = [control retain];
	[self.contentView addSubview:_control];
	[self.contentView sendSubviewToBack:_control];
	[self layoutSubviews];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect	contentRect = [self.contentView bounds];
	
	CGRect	frame = CGRectMake(contentRect.origin.x + kCellLeftOffset, kCellTopOffset, contentRect.size.width - 2 * kCellLeftOffset, kCellHeight);
	label.frame = frame;

	CGRect	frame1 = CGRectMake(230, kCellTopOffset, 25.0, 25.0);
	frame1.origin.y = self.frame.size.height / 2 - details.frame.size.height / 2;
	details.frame = frame1;
	
	if ( _control )
	{
		frame1.origin.y = self.frame.size.height / 2 - details.frame.size.height / 2;
		details.frame = frame1;
		
		CGRect	controlFrame = CGRectMake(10,10,260,64);
		_control.frame = controlFrame;
	}
}

- (void)dealloc
{
	[label release];
	[_control release];
	
    [super dealloc];
}

-(void)doDetail:(id)sender
{
	if ( self.delegate && [self.delegate respondsToSelector:@selector(detailsSelected:)] )
		[self.delegate performSelector:@selector(detailsSelected:) withObject:self.context];
}

-(BOOL)details
{
	return details.alpha == 1.0;
}

-(void)setDetails:(BOOL)on
{
	details.alpha = on ? 1.0 : 0.0;
}

@end
