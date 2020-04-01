//
//  PrefFileViewController.m
//  Board3
//
//  Created by Dror Kessler on 8/11/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "PrefFileViewController.h"
#import "L.h"
#import "RTLUtils.h""

@implementation PrefFileViewController
@synthesize path = _path;

-(id)initWithArgument:(NSObject*)path
{
	if ( self = [super init] )
	{
		self.path = (NSString*)path;
	}
	return self;
}

-(void)dealloc
{
	[_path release];
	
	[super dealloc];
}

- (void)loadView 
{
	self.title = RTL([self.path lastPathComponent]);
	
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	
	// add view based in content type
	NSString*		ext = [self.path pathExtension];
	CGRect			frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	
	if ( [ext isEqualToString:@"txt"] || [ext isEqualToString:@"plist"] )
	{
		NSError*			error;
		NSStringEncoding	encoding;
		UITextView*			textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
		[self.view addSubview:textView];
		
		NSMutableString*	text = [NSMutableString stringWithContentsOfFile:self.path usedEncoding:&encoding error:&error];
		NSRange				range = NSMakeRange(0, [text length]);
		[text replaceOccurrencesOfString:@"\t" withString:@"  " options:0 range:range];
		textView.text = text;
		textView.editable = FALSE;
	}
	else if ( [ext isEqualToString:@"jpg"] )
	{
		UIImage*			image = [UIImage imageWithContentsOfFile:self.path];
		UIImageView*		imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
		[self.view addSubview:imageView];
		
		imageView.image = image;
		imageView.contentMode = UIViewContentModeCenter;
		
	}

}


@end
