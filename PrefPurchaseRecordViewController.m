//
//  PrefPurchaseRecordViewController.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "PrefPurchaseRecordViewController.h"
#import "StoreManager.h"
#import "L.h"
#import "RTLUtils.h"

@implementation PrefPurchaseRecordViewController

@synthesize billingItem = _billingItem;

-(id)initWithArgument:(NSObject*)billingItem;
{
	if ( self = [super init] )
	{
		self.billingItem = (NSString*)billingItem;
	}
	return self;
}

-(void)dealloc
{
	[_billingItem release];
	
	[super dealloc];
}

-(void)loadView 
{
	PurchaseRecord*		pr = [[StoreManager singleton] findOrCreatePurchaseRecordForBillingItem:_billingItem];
	NSDictionary*		dict = [pr dictionaryRepresentation];
	
	NSString*			errorString;
	NSData*				data = [NSPropertyListSerialization dataFromPropertyList:dict 
																  format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
	if ( !data || errorString )
	{
		NSLog(@"ERROR - %@", errorString);
		return;
	}
	NSMutableString*	text = [[[NSMutableString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding] autorelease];
	
	self.title = RTL([pr displayName]);
	
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.view.backgroundColor = [UIColor blackColor];

	CGRect				frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);	
	UITextView*			textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
	[self.view addSubview:textView];
	
	NSRange				range = NSMakeRange(0, [text length]);
	[text replaceOccurrencesOfString:@"\t" withString:@"  " options:0 range:range];
	textView.text = text;
	textView.editable = FALSE;
}

@end
