//
//  PrefAbraViewController.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefAbraViewController.h"
#import "Constants.h"
#import "CellTextField.h"
#import "CellTextView.h"
#import "TextSpeaker.h"

extern CGRect  globalFrame;

// the amount of vertical shift upwards keep the text field in view as the keyboard appears
#define kOFFSET_FOR_KEYBOARD					150.0

// the duration of the animation for the view shift
#define kVerticalOffsetAnimationDuration		0.30

#define kUITextField_Section					0
#define kUITextField_Rounded_Custom_Section		1
#define kUITextField_Secure_Section				2


@interface PrefAbraViewController (Privates)
-(UITextField*)createTextField;
-(UITextView*)createTextView;
-(void)send:(NSString*)question;
-(NSString*)findTag:(NSString*)tag inString:(NSString*)string;
-(NSString*)findAttr:(NSString*)attr inString:(NSString*)string;
@end

@implementation PrefAbraViewController
@synthesize textField = _textField;
@synthesize textView = _textView;
@synthesize url = _url;
@synthesize sessionID = _sessionID;



-(id)initWithArgument:(NSObject*)initialQuestion
{
	if ( self = [super init] )
	{
		self.url = [NSURL URLWithString:@"http://www.a-i.com/alan1/vp2.asp"];
	}
	return self;
}

-(void)dealloc
{
	[_textField release];
	[_textView release];
	[_url release];
	[_sessionID release];
	
	[super dealloc];
}

-(void)loadView 
{
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	self.view.backgroundColor = [UIColor whiteColor];

	self.textField = [self createTextField];
	self.textView = [self createTextView];
	
	[self.view addSubview:_textField];
	[self.view addSubview:_textView];
}

-(void)viewDidAppear:(BOOL)animated
{
	[_textField becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	[self send:_textField.text];
	
	return NO;
}

-(void)send:(NSString*)question
{
	NSCharacterSet*		whiteSpaces = [NSCharacterSet whitespaceCharacterSet];
	
	// append question to log
	NSLog(@"send: question=%@", question);
	question = [question stringByTrimmingCharactersInSet:whiteSpaces];
	_textView.text = [NSString stringWithFormat:@"U> %@\n%@", question, _textView.text];
	[TextSpeaker speak:[NSString stringWithFormat:@"-- %@", question]];
	
	// build url
	NSMutableString*		urlString = [NSMutableString stringWithString:[_url absoluteString]];
	[urlString appendFormat:@"?question=%@", [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	if ( _sessionID )
		[urlString appendFormat:@"&session-id=%@", _sessionID];
	NSURL*					url = [NSURL URLWithString:urlString];
	
	// execute query
	NSString*				response = [NSString stringWithContentsOfURL:url];
	NSLog(@"send: response=%@", response);
	if ( !response )
		return;
	
	// parse response
	NSString*				answer = [self findTag:@"answer" inString:response];
	NSLog(@"send: answer=%@", answer);
	if ( answer )
	{
		answer = [answer stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
		answer = [answer stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
		answer = [answer stringByTrimmingCharactersInSet:whiteSpaces];
		_textView.text = [NSString stringWithFormat:@"A> %@\n%@", answer, _textView.text];
		[TextSpeaker speak:answer];
	}
	
	// session id
	self.sessionID = [self findAttr:@"session-id" inString:response];
	
	// display name
	NSString*				displayName = [self findTag:@"display-name" inString:response];
	if ( displayName )
		self.title = displayName;
	
	// clear text box
	_textField.text = @"";
	
	// make top of log visible
	[self performSelector:@selector(scrollToTop:) withObject:self afterDelay:0.3];
}

-(void)scrollToTop:(id)sender
{
	[_textView scrollRangeToVisible:NSMakeRange(0, 10)];	
}

-(NSString*)findTag:(NSString*)tag inString:(NSString*)string
{
	NSString*		open = [NSString stringWithFormat:@"<%@>", tag];
	NSString*		close = [NSString stringWithFormat:@"</%@>", tag];
	
	NSRange			openRange = [string rangeOfString:open];
	NSRange			closeRange = [string rangeOfString:close];
	
	if ( openRange.length <= 0 || closeRange.length <= 0 )
		return NULL;
	
	NSRange			textRange;
	textRange.location = openRange.location + openRange.length;
	textRange.length = closeRange.location - textRange.location;
	
	return [string substringWithRange:textRange];
}

-(NSString*)findAttr:(NSString*)attr inString:(NSString*)string
{
	NSString*		open = [NSString stringWithFormat:@"%@=\"", attr];
	NSString*		close = @"\"";
	
	NSRange			openRange = [string rangeOfString:open];
	if ( openRange.length <= 0 )
		return NULL;
	NSRange			closeRange = [string rangeOfString:close options:0 range:NSMakeRange(openRange.location + openRange.length, [string length] - openRange.location - openRange.length)];
	if ( closeRange.length <= 0 )
		return NULL;
	
	NSRange			textRange;
	textRange.location = openRange.location + openRange.length;
	textRange.length = closeRange.location - textRange.location;
	
	return [string substringWithRange:textRange];
}


- (UITextField *)createTextField
{
    CGRect frame = CGRectMake(0.0, 0.0, globalFrame.size.width, kTextFieldHeight);
	UITextField *returnTextField = [[[UITextField alloc] initWithFrame:frame] autorelease];
    
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:17.0];
    returnTextField.placeholder = @"<enter text>";
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	returnTextField.returnKeyType = UIReturnKeySend;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	returnTextField.delegate = self;
	
	return returnTextField;
}

- (UITextView *)createTextView
{
    CGRect frame = CGRectMake(0.0, kTextFieldHeight, globalFrame.size.width, self.view.frame.size.height - kTextFieldHeight);
	
	UITextView*	textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont fontWithName:kFontName size:kTextViewFontSize];
    textView.backgroundColor = [UIColor whiteColor];
	
	textView.editable = FALSE;
	textView.scrollEnabled = TRUE;
	
	// note: for UITextView, if you don't like autocompletion while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return textView;
}


	
	
@end
