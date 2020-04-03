//
//  SplashPanel.m
//  Board3
//
//  Created by Dror Kessler on 9/2/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "SplashPanel.h"
#import "SystemUtils.h"
#import "Folders.h"
#import "NSDictionary_TypedAccess.h"
#import	<QuartzCore/QuartzCore.h>
#import "TextSpeaker.h"
#import "L.h"

@interface SplashPanel (Privates)
-(SplashPanelView*)buildView;
@end

extern BOOL		applicationResigned;


@implementation SplashPanel
@synthesize title = _title;
@synthesize text = _text;
@synthesize icon = _icon;
@synthesize delegate = _delegate; // assign
@synthesize view = _view;
@synthesize width = _width;
@synthesize height = _height;
@synthesize autoShow = _autoShow;
@synthesize minShowTime = _minShowTime;
@synthesize textFontSize;
@synthesize alertController = _alertController;
@synthesize buttonText = _buttonText;
@synthesize props = _props;

-(id)init
{
	if ( self = [super init] )
	{
		self.width = 240;
		self.height = 310;
		self.minShowTime = 0.33;
		self.textFontSize = 14;
		self.props = [NSMutableDictionary dictionary];
	}
	
	return self;
}

-(void)dealloc
{
	[_title release];
	[_text release];
	[_icon release];
	
	[_view setModel:nil];
	[_view release];
	
	[_alertController release];
	[_buttonText release];
	[_props release];
	
	[super dealloc];
}

-(void)show
{
	if ( _alertController )
		return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_title message:_text preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:_buttonText ? _buttonText : LOC(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [self.delegate splashDidFinish:self];    
                        }];
#if 0
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:self];
    [alert addAction:cancel];
#endif
    [alert addAction:ok];
    self.alertController = alert;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window.rootViewController presentViewController:alert animated:YES completion:nil];

    if ( [SystemUtils autorun] )
		[self performSelector:@selector(hide) withObject:self afterDelay:2.6];
}

-(void)showAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	self.view.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];			
}

-(void)hide
{
	if ( !_alertController )
		return;
	
    
    [_alertController dismissViewControllerAnimated:true completion:nil];
	self.alertController = nil;

	if ( _delegate && [_delegate respondsToSelector:@selector(splashDidFinish:)] )
		[self.delegate splashDidFinish:self];
}

-(void)abort
{
	self.delegate = nil;
	
	[self hide];
}

-(void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	UIView*		view = context;
	
	[view removeFromSuperview];
}

extern CGRect  globalFrame;

-(SplashPanelView*)buildView
{
    float			x = (globalFrame.size.width - _width) / 2;
    float			y = (globalFrame.size.height - _height) / 2;
	CGRect			frame = CGRectMake(x, y, _width, _height);
	
	SplashPanelView*	view = [[[SplashPanelView alloc] initWithFrame:frame andModel:self] autorelease];
	
	return view;
}

-(void)onTouched
{
	if ( ![SystemUtils autorun] && ([[NSDate date] timeIntervalSince1970] - shownAt) < _minShowTime )
		return;
	
	[self hide];
}

+(SplashPanel*)splashPanelWithProps:(NSDictionary*)props forUUID:(NSString*)uuid inDomain:(NSString*)domain 
										withDelegate:(id<SplashPanelDelegate>)delegate
{
	if ( !props )
		return NULL;
	
	SplashPanel*	splash = [[[SplashPanel alloc] init] autorelease];
	
	splash.title = [props objectForKey:@"title"];
	splash.text = [props objectForKey:@"text"];
	splash.autoShow = [props booleanForKey:@"auto-show" withDefaultValue:FALSE];
	
	NSString*			imageName = [props objectForKey:@"icon"];
	if ( imageName )
	{
		NSString*	folder = [Folders findUUIDSubFolder:NULL forDomain:domain withUUID:uuid];
		if ( folder )
		{
			splash.icon = [UIImage imageWithContentsOfFile:[folder stringByAppendingPathComponent:imageName]];
		}
	}
		
	splash.delegate = delegate;
	
	return splash;
}

-(BOOL)shown
{
	return _alertController != NULL;
}

-(void)toggle
{
	if ( ![self shown] )
		[self show];
	else
	{
		[self hide];
	}
}

#if 0
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
}

-(void)didPresentAlertView:(UIAlertView *)alertView
{
	[self retain];
	if ( _delegate && [_delegate respondsToSelector:@selector(splashDidShow:)] )
		[self.delegate splashDidShow:self];	
	[self autorelease];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
	//NSLog(@"****** alertView:didDismissWithButtonIndex: applicationResigned=%d", applicationResigned);	

	if ( applicationResigned )
	{
		//NSLog(@"****** alertView:didDismissWithButtonIndex: ignored");
		return;
	}
	//[TextSpeaker speak:[NSString stringWithFormat:@"alert View did Dismiss With Button Index %d", buttonIndex]];
	
	[self retain];
	if ( _delegate && [_delegate respondsToSelector:@selector(splashDidFinish:)] )
		[self.delegate splashDidFinish:self];	

	self.alertView = nil;
	[self autorelease];
}
#endif


@end
