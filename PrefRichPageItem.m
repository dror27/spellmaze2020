//
//  PrefRichPageItem.m
//  SpellMaze
//
//  Created by Dror Kessler on 12/13/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefRichPageItem.h"
#import	<QuartzCore/QuartzCore.h>
#import "BrandManager.h"
#import "UIImage_ResizeImageAllocator.h"

#define	CONTROL_WIDTH		260
#define	CONTROL_HEIGHT		64
#define	CONTROL_MARGIN		10

@interface PrefRichPageItem (Privates) 
-(void)setUILabel:(UILabel *)myLabel withMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(int)vertAlign;
@end



@implementation PrefRichPageItem
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize icon = _icon;
@synthesize iconView = _iconView;
@synthesize iconUrl = _iconUrl;
@synthesize iconUrlConnection = _iconUrlConnection;
@synthesize iconData = _iconData;
@synthesize narrow;

-(void)dealloc
{
	[_title release];
	[_subtitle release];
	[_icon release];
	[_iconView release];
	[_iconUrl release];
	
	[_iconUrlConnection cancel];
	[_iconUrlConnection release];
	
	
	[_iconData release];
	
	[super dealloc];
}


-(UIView*)control
{
	if ( !_control )
	{
		CGRect			frame = CGRectMake(0.0, 0.0, CONTROL_WIDTH, CONTROL_HEIGHT);
		
		self.iconView = nil;
		if ( !_icon )
		{
			self.icon = [[BrandManager currentBrand] globalImage:@"directory-item-icon" withDefaultValue:NULL];
			if ( !_icon )
				self.icon = [UIImage imageNamed:@"spellmaze_logo_64x64.png"];
		}
		
		if ( _icon )
		{
			CGRect			iconRect = CGRectMake(0, 0, 64, 64);
			UIImageView*	iconView1 = [[[UIImageView alloc] initWithFrame:iconRect] autorelease];
			iconView1.image = _icon;
			iconView1.layer.cornerRadius = 5;
			iconView1.layer.masksToBounds = YES;
			iconView1.contentMode = UIViewContentModeScaleAspectFill;
			iconView1.backgroundColor = [UIColor clearColor];
			
			self.iconView = [[[UIImageView alloc] initWithFrame:iconRect] autorelease];
			_iconView.backgroundColor = [UIColor clearColor];
			_iconView.image = [UIImage imageWithView:iconView1 scaledToSize:iconRect.size];
		}
		
		float			titleWidth = CONTROL_WIDTH - 64 - 4;
		float			subtitleWidth = titleWidth;
		if ( narrow )
			subtitleWidth -= 40;
		
		CGRect			titleRect = CGRectMake(0 + 70, 0 + 0, titleWidth, 24);
		UILabel*		titleLabel = [[[UILabel alloc] initWithFrame:titleRect] autorelease];
		titleLabel.text = _title;
		titleLabel.font = [UIFont boldSystemFontOfSize:18];
		titleLabel.contentMode = UIViewContentModeTopLeft; 
		titleLabel.backgroundColor = [UIColor clearColor];
		
		CGRect			subtitleRect = CGRectMake(0 + 70, 0 + titleRect.size.height, subtitleWidth, 40);
		UILabel*		subtitleLabel = [[[UILabel alloc] initWithFrame:subtitleRect] autorelease];
		subtitleLabel.text = _subtitle;
		subtitleLabel.font = [UIFont systemFontOfSize:14];
		subtitleLabel.contentMode = UIViewContentModeBottomLeft;
		subtitleLabel.backgroundColor = [UIColor clearColor];
		subtitleLabel.lineBreakMode = UILineBreakModeWordWrap;
		subtitleLabel.numberOfLines = 0;
		[self setUILabel:subtitleLabel withMaxFrame:subtitleRect withText:_subtitle usingVerticalAlign:2];
		
		UIView*			view = [[[UIView alloc] initWithFrame:frame] autorelease];
		view.backgroundColor = [UIColor clearColor];
		if ( _iconView )
			[view addSubview:_iconView];
		[view addSubview:titleLabel];
		[view addSubview:subtitleLabel];
		
		self.control = view;
		
		// if has url -> fire an update using the picture behind the url
		if ( _iconUrl )
		{
			NSURLRequest*		request = [NSURLRequest requestWithURL:_iconUrl];
		
			self.iconData = [NSMutableData data];
			self.iconUrlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
		}
	}
	
	return _control;
}

-(float)rowHeight
{
	return CONTROL_HEIGHT + 2 * CONTROL_MARGIN;
}

-(void)setUILabel:(UILabel *)myLabel withMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(int)vertAlign 
{
	CGSize stringSize = [theText sizeWithFont:myLabel.font constrainedToSize:maxFrame.size lineBreakMode:myLabel.lineBreakMode];
	
	switch (vertAlign) {
		case 0: // vertical align = top
			myLabel.frame = CGRectMake(myLabel.frame.origin.x, 
									   myLabel.frame.origin.y, 
									   myLabel.frame.size.width, 
									   stringSize.height
									   );
			break;
			
		case 1: // vertical align = middle
			// don't do anything, lines will be placed in vertical middle by default
			break;
			
		case 2: // vertical align = bottom
			myLabel.frame = CGRectMake(myLabel.frame.origin.x, 
									   (myLabel.frame.origin.y + myLabel.frame.size.height) - stringSize.height, 
									   myLabel.frame.size.width, 
									   stringSize.height
									   );
			break;
	}
	
	myLabel.text = theText;
}


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_iconData setLength:0];	
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_iconData appendData:data];		
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{	
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	UIImage*	newIcon = [UIImage imageWithData:_iconData];
	
	_iconView.image = newIcon;
}


@end
