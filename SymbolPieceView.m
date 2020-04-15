//
//  SymbolPieceView.m
//  Board3
//
//  Created by Dror Kessler on 5/8/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "SymbolPieceView.h"
#import "SymbolPiece.h"
#import "UIImage_TextRepresentation.h"
#import "UIImage_ResizeImageAllocator.h"
#import "BrandManager.h"
#import	<QuartzCore/QuartzCore.h>
#import "UserPrefs.h"
#import "ImageWithUUID.h"
#import "UUIDUtils.h"
#import "GameLevel.h"
#import "Folders.h"
#import "JokerUtils.h"
#import "ViewController.h"

#define	WRITE_IMAGES		0

//#define	MEASURE

#ifdef MEASURE
clock_t		startedAt;
#endif


extern NSMutableDictionary*	globalData;
#define IMAGES_KEY		@"SymbolPieceView_images"

#define	IMAGES_HIGH_THRESHOLD			128
#define	IMAGES_HIGH_THRESHOLD_INGAME	256
#define	IMAGES_LOW_THRESHOLD			64

#define	ANIM_DURATION	0.2
#define	ANIM_DURATION2	(fastAnimations ? 0.2 : 0.4)
#define	ANIM_DURATION4	(fastAnimations ? 0.4 : 0.8)

#define	FABS(f)				(((f) < 0) ? -(f) : (f))

// color table
static NSMutableArray*	colorTable = NULL;
static NSMutableArray*	textColorTable = NULL;
static int				customColorsOffset = 0;
static BOOL				customMasks = FALSE;
static BOOL				customOverlays = FALSE;

@interface SymbolPieceView (Privates)
-(UILabel*)buildTextLabelWithFrame:(CGRect)frame;

+(void)initColorTable;
+(int)getStringIndex:(NSString*)s;
-(UIColor*)getColorForIndex:(int)index;
-(UIColor*)getTextColorForIndex:(int)index;

+(NSMutableDictionary*)imageDict;
-(void)clearImageDict;
-(NSString*)imageDictKey:(BOOL)fadeMask;
@end


@implementation SymbolPieceView
@synthesize model = _model;
@synthesize lastScreenX;
@synthesize lastScreenY;
@synthesize lastScreenSize;
@synthesize contentView = _contentView;
@synthesize fadeView = _fadeView;
@synthesize noFadeView;

-(id)retain
{
	return [super retain];
}

- (id)initWithFrame:(CGRect)frame andModel:(SymbolPiece*)initModel {
	
    if (self = [super initWithFrame:frame]) 
	{
		[SymbolPieceView initColorTable];
		
		self.model = initModel;
		
		fastAnimations = [[[[_model cell] board] level] fastGame];
		
		[self updateText];
		
		[[BrandManager singleton] addDelegate:self];
    }
    return self;
}

-(void)dealloc
{
	[[BrandManager singleton] removeDelegate:self];
	[_contentView release];
	[_fadeView release];
	
	[super dealloc];
}


-(void)rotationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
}

-(float)screenX:(UIView*)view
{
	if ( view )
		return [view frame].origin.x + [self screenX:[view superview]];
	else
		return 0;
}
-(float)screenY:(UIView*)view
{
	if ( view )
		return [view frame].origin.y + [self screenY:[view superview]];
	else
		return 0;
}

-(void)dumpCenterOf:(UIView*)view
{
	if ( view )
	{
		printf("dumpCenterOf: center=%f,%f frame.origin=%f,%f frame.size=%f,%f\n",
					[view center].x, [view center].y,
					[view frame].origin.x, [view frame].origin.y,
					[view frame].size.width, [view frame].size.height);
		[self dumpCenterOf:[view superview]];
	}
	else
		printf("----------------\n");
}

-(void)placed
{
	float		lastX = lastScreenX;
	float		lastY = lastScreenY;
	BOOL		move = (lastX != 0) || (lastY != 0);
#ifdef ADVANCED_SCALING
	BOOL		scale = !CGSizeEqualToSize(self.frame.size, lastScreenSize);
#else
	BOOL		scale = false;
#endif

	
	lastScreenX = [self screenX:self];
	lastScreenY = [self screenY:self];

	CGPoint		center = [self center];
	CGPoint		newCenter = center;
	newCenter.x += (lastX - lastScreenX);
	newCenter.y += (lastY - lastScreenY);
	/*
	if ( [_model symbol] == 'Z' )
		NSLog(@"center=%f,%f newCenter=%f,%f", center.x, center.y, newCenter.x, newCenter.y);
	*/
	
	if ( move )
		self.center = newCenter;
	else
		self.alpha = 0.0;
	if ( scale )
	{
		float		dx = (lastScreenSize.width - self.frame.size.width) / 2;
		float		dy = (lastScreenSize.height - self.frame.size.height) / 2;

		float		widthFactor = lastScreenSize.width / self.frame.size.width;
		float		heightFactor = lastScreenSize.height / self.frame.size.height;
		self.transform = CGAffineTransformMakeScale(widthFactor, heightFactor);	
		
		newCenter.x = newCenter.x + dx;
		newCenter.y = newCenter.y + dy;
		self.center = newCenter;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_DURATION2];
	if ( move )
		self.center = center;
	else
		self.alpha = 1.0;
	if ( scale )
		self.transform = CGAffineTransformIdentity;

	[UIView commitAnimations];
	
	lastScreenSize = self.frame.size;
}

-(float)fade
{
	return fade;
}

-(void)setFade:(float)newFade
{
	if ( fade == newFade )
		return;
	
	if ( !_fadeView && !noFadeView && newFade != 0.0 )
	{
		self.fadeView = [self buildContentView:TRUE];
		_fadeView.alpha = 0;
	}
	
	if ( _fadeView )
	{
		// add remove fade view
		if ( fade == 0.0 && newFade != 0.0 )
			[_contentView addSubview:_fadeView];
		else if ( fade != 0.0 && newFade == 0.0 )
			[_fadeView removeFromSuperview];
		
		// saving CPU by not animating this ...
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ANIM_DURATION2];
		_fadeView.alpha = fade = newFade;
		[UIView commitAnimations];	
	}
	else
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ANIM_DURATION2];
		_contentView.alpha = 1 - (fade = newFade);
		[UIView commitAnimations];			
	}
}

-(BOOL)disabled
{
	return disabled;
}

-(void)setDisabled:(BOOL)newDisabled
{
	if ( disabled != newDisabled )
	{
		disabled = newDisabled;

		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ANIM_DURATION];
		if ( !hidden )
			_contentView.alpha = !disabled ? 1.0 : 0.33;
		else
			_contentView.alpha = 0;
		[UIView commitAnimations];	
	}
}

-(BOOL)hidden
{
	return hidden;
}

-(void)setHidden:(BOOL)newHidden
{
	if ( hidden != newHidden )
	{
		hidden = newHidden;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:ANIM_DURATION];
		if ( !hidden )
			_contentView.alpha = !disabled ? 1.0 : 0.33;
		else
			_contentView.alpha = 0;
		[UIView commitAnimations];	
	}
}

-(void)hinted:(BOOL)last
{
	[UIView beginAnimations:nil context:(last ? self : NULL)];
	[UIView setAnimationDuration:ANIM_DURATION];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hintedAnimationDidStop:finished:context:)];
	self.transform = CGAffineTransformMakeScale(1.7, 1.7);
	self.alpha = 0.8;
	[UIView commitAnimations];	
}
-(void)hintedAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	BOOL		last = context != NULL;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_DURATION];
	if ( last )
	{
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hintedAnimationDidStop2:finished:context:)];
	}
	self.transform = CGAffineTransformMakeScale(1.0, 1.0);
	self.alpha = 1.0;
	[UIView commitAnimations];
	
}
-(void)hintedAnimationDidStop2:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[self hinted:FALSE];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
		
	[self click];
}

-(void)click
{
	if ( !disabled )
		[_model clicked];	
	else
		[_model disabledClicked];
}

-(void)updateSelected:(BOOL)isSelected
{
	// make sure model sticks around
	[_model retain];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_DURATION];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	//self.transform = CGAffineTransformMakeRotation(isSelected ? 3 : -3);
	self.transform = CGAffineTransformMakeScale(isSelected ? 1.7 : 1.0, isSelected ? 1.7 : 1.0);
	self.alpha = isSelected ? 0.8 : 1.0;
	[UIView commitAnimations];	
	
	lastScreenX = [self screenX:self];
	lastScreenY = [self screenY:self];
	lastScreenSize = self.frame.size;
	
}


-(void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
	// let model go
	[_model autorelease];

	BOOL	isSelected = [_model isSelected];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ANIM_DURATION];
	self.transform = CGAffineTransformMakeScale(isSelected ? 1.4 : 1.0 , isSelected ? 1.4 : 1.0);	
	[UIView commitAnimations];
	
	lastScreenX = [self screenX:self];
	lastScreenY = [self screenY:self];
	lastScreenSize = self.frame.size;
}

extern CGRect  globalFrame;

-(void)eliminate
{
	CGPoint		newCenter = self.center;
	newCenter.x -= lastScreenX;
	newCenter.y -= lastScreenY;
	if ( rand() % 2 )
        newCenter.x += globalFrame.size.width;
	if ( rand() % 2 )
        newCenter.y += globalFrame.size.height;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:ANIM_DURATION4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(eliminateAnimationDidStop:finished:context:)];
	self.center = newCenter;
	self.transform = CGAffineTransformMakeScale(2, 2);
	self.alpha = 0.25;
	[UIView commitAnimations];	
}

-(void)eliminateAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[self removeFromSuperview];
}
	
-(void)examine
{
	if ( _contentView )
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:ANIM_DURATION];
		_contentView.transform = CGAffineTransformMakeScale(2, 2);
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(examineAnimationDidStop:finished:context:)];
		[UIView commitAnimations];		
	}
}

-(void)examineAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	if ( _contentView )
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:ANIM_DURATION];
		_contentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
		[UIView commitAnimations];		
	}
}


+(void)initColorTable
{
	if ( colorTable )
		return;
	
	colorTable = [[NSMutableArray alloc] init];
	textColorTable = [[NSMutableArray alloc] init];
	
	Brand*		brand = [BrandManager currentBrand];
	
	customColorsOffset = [brand globalInteger:@"skin/props/piece-colors-offset" withDefaultValue:0];
	customMasks = [brand globalBoolean:@"skin/props/piece-custom-masks" withDefaultValue:FALSE];
	customOverlays = [brand globalBoolean:@"skin/props/piece-custom-overlays" withDefaultValue:FALSE];
	
	int			customColors = [brand globalInteger:@"skin/props/piece-custom-colors" withDefaultValue:0];
	
	if ( customColors )
	{
		UIColor*	defaultColor = [UIColor redColor];
		UIColor*	defaultTextColor = [UIColor blackColor];
		
		for ( int index = 0 ; index < customColors ; index++ )
		{
			[colorTable addObject:[brand globalColor:[NSString stringWithFormat:@"piece-custom-color-%d", index] withDefaultValue:defaultColor]];
			[textColorTable addObject:[brand globalColor:[NSString stringWithFormat:@"piece-custom-text-color-%d", index] withDefaultValue:defaultTextColor]];
		}
	}
	else
	{
		BOOL	blackPiece = [brand globalBoolean:@"skin/props/dark-pref-button" withDefaultValue:FALSE];
				
		for ( float red1 = 0 ; red1 <= 1 ; red1 += 0.5 )
			for ( float green1 = 0 ; green1 <= 1 ; green1 += 0.5 )
				for ( float blue1 = 0 ; blue1 <= 1 ; blue1 += 0.5 )
				{
					float	red = red1;
					float	green = green1;
					float	blue = blue1;
					
					float	energy = red + green + blue;
					
					
					if ( energy > 0 )
					{
						/*
						printf("%2.2X%2.2X%2.2X\n", 
							  red == 0 ? 0x00 : (red == 1.0 ? 0xFF : 0x80),
							  green == 0 ? 0x00 : (green == 1.0 ? 0xFF : 0x80),
							  blue == 0 ? 0x00 : (blue == 1.0 ? 0xFF : 0x80)
							  );
						 */
						 
						//NSLog(@"[SymbolPieceView] RGB %f %f %f energy %f", red, green, blue, energy);
					
						if ( blackPiece && energy >= 3.0 )
						{
							[colorTable addObject:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]];
							[textColorTable addObject:[UIColor whiteColor]];							
						}
						else
						{
							[colorTable addObject:[UIColor colorWithRed:red green:green blue:blue alpha:1.0]];
							[textColorTable addObject:(energy > 0.5) ? [UIColor blackColor] : [UIColor whiteColor]];
						}
					}
				}
		
		//NSLog(@"[SymbolPieceView] - colorTable size %d", [colorTable count]);
		
		// swap positions 25(M) and 7(U) to make M be cyan
		[colorTable exchangeObjectAtIndex:25 withObjectAtIndex:7];
		[textColorTable exchangeObjectAtIndex:25 withObjectAtIndex:7];
						
	}
}

+(int)getStringIndex:(NSString*)s
{
	if ( [s length] == 1 && [s characterAtIndex:0] == [JokerUtils jokerCharacter]
			&& [[BrandManager currentBrand] globalColor:@"joker-custom-color" withDefaultValue:nil] )
		return -1;
	
	int			index = 0;
	
	// check for sssssssssss/C/
	if ( [s hasSuffix:@"/"] )
	{
		NSArray*	comps = [s componentsSeparatedByString:@"/"];
		int			compsCount = [comps count];
		
		return [SymbolPieceView getStringIndex:[comps objectAtIndex:MAX(compsCount, 2) - 2]];
	}
	
	for ( int n = 0 ; n < [s length] ; n++ )
		index += [s characterAtIndex:n];
	
	return index;
}

-(UIColor*)getColorForIndex:(int)index
{
	if ( index < 0 )
	{
		UIColor*		color = [[BrandManager currentBrand] globalColor:@"joker-custom-color" withDefaultValue:nil];
		if ( color )
			return color;
	}
	
	NSNumber*	num = [_model.props objectForKey:SYMBOL_PIECE_POS_COLOR_HINT];
	int			mod;
	if ( num && ((mod = [[BrandManager currentBrand] globalInteger:@"skin/props/chess-colors-mod" withDefaultValue:0]) > 1) )
	{
		int			row = [num intValue] / 100;
		int			col = [num intValue] % 100;
	
		index = (col + (row % mod)) % mod;
		
		UIColor*	color = [[BrandManager currentBrand] globalColor:[NSString stringWithFormat:@"chess-color-%d", index] withDefaultValue:NULL];
		if ( color )
			return color;
	}
	
	return (UIColor*)[colorTable objectAtIndex:((index + customColorsOffset) % [colorTable count])];
	
}

-(UIColor*)getTextColorForIndex:(int)index
{
	if ( index < 0 )
	{
		UIColor*		color = [[BrandManager currentBrand] globalColor:@"joker-custom-text-color" withDefaultValue:nil];
		if ( color )
			return color;
	}
	
	NSNumber*	num = [_model.props objectForKey:SYMBOL_PIECE_POS_COLOR_HINT];
	int			mod;
	if ( num && ((mod = [[BrandManager currentBrand] globalInteger:@"skin/props/chess-colors-mod" withDefaultValue:0]) > 1) )
	{
		int			row = [num intValue] / 100;
		int			col = [num intValue] % 100;
		
		index = (col + (row % mod)) % mod;
		
		UIColor*	color = [[BrandManager currentBrand] globalColor:[NSString stringWithFormat:@"chess-text-color-%d", index] withDefaultValue:NULL];
		if ( color )
			return color;
	}
	
	return (UIColor*)[textColorTable objectAtIndex:((index + customColorsOffset) % [textColorTable count])];
}

-(void)brandDidChange:(Brand*)brand
{
	[self clearImageDict];

	@synchronized ([self class])
	{
		// possible change in color scheme ...
		if ( colorTable )
		{
			[colorTable autorelease];
			colorTable = NULL;
			
			[textColorTable autorelease];
			textColorTable = NULL;
		}
		[SymbolPieceView initColorTable];
	}
	
	[self updateText];
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	// brute force ...
	[self brandDidChange:[BrandManager currentBrand]];
}

-(void)updateText
{
	// guard against inflated image dict
	[SymbolPieceView guardImageDictSize:FALSE];
	
	// reset content view
	if ( _contentView )
	{
		for ( UIView* view in [_contentView subviews] )
			[view removeFromSuperview];
		[_contentView removeFromSuperview];
		self.contentView = nil;
	}

	self.contentView = [self buildContentView:FALSE];

	[self addSubview:_contentView];
}

-(UIView*)buildContentView:(BOOL)fadeMask
{
	UIView*		contentView;
	Brand*		brand = [BrandManager currentBrand];
	
	// figure out image key, use it if already exists
	NSString*		imageKey = [self imageDictKey:fadeMask];
	ImageWithUUID*	contentImage = nil;
	if ( imageKey )
		contentImage = [[SymbolPieceView imageDict] objectForKey:imageKey];
	if ( !contentImage )
	{
		//NSLog(@"updateImage: creating image for %@", imageKey);
		
#ifdef	MEASURE
		startedAt = clock();
#endif		
				
		CGRect		frame = self.frame;
#if 0
        frame.size.height = frame.size.width = 1024;
#endif
		colorIndex = [SymbolPieceView getStringIndex:[_model text]];
		
		if ( fadeMask )
		{
			contentView = [[[UIView alloc] initWithFrame:frame] autorelease];

			[contentView setBackgroundColor:[self getColorForIndex:colorIndex]];
		}
		else if ( ![_model image] && [[_model text] length] < 32 )
		{
			UILabel* label = [self buildTextLabelWithFrame:frame];
			contentView = label;
			
			UIColor*	shadowColor = [brand globalColor:@"piece-shadow-color" withDefaultValue:NULL];
			if ( shadowColor )
			{
				float		x = [brand globalFloat:@"skin/props/piece-shadow-x" withDefaultValue:0.0];
				float		y = [brand globalFloat:@"skin/props/piece-shadow-y" withDefaultValue:0.0];
			
				label.shadowColor = shadowColor;
				label.shadowOffset = CGSizeMake(x,y);
			}			
		}
		else
		{
			UIImage*	image = [_model image];
			if ( !image )
				image = [[[UIImage imageFromTextRepresentation:[_model text]] retain] autorelease];
			
			float	imageAspect = image.size.width / image.size.height;
			float	frameAspect = frame.size.width / frame.size.height;\
			float	delta = 1.0 - imageAspect / frameAspect;
			//NSLog(@"delta: %f", delta);
			BOOL	aspectCloseEnough;
			if ( FABS(delta) < 0.34 )
				aspectCloseEnough = TRUE;
			else
				aspectCloseEnough = FALSE;
			
			UIImageView* imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
			imageView.contentMode = aspectCloseEnough ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
			if ( [[BrandManager currentBrand] globalBoolean:@"skin/props/show-symbol-color" withDefaultValue:TRUE] )
				imageView.backgroundColor = [self getColorForIndex:colorIndex];
			else
				imageView.backgroundColor = [UIColor clearColor];
			imageView.image = image;
			contentView = imageView;
			
			if ( [_model showSymbolText] && MIN(frame.size.width, frame.size.height) > 40 )
			{
				float		width = frame.size.width / 3;
				float		height = frame.size.height / 3;
				CGRect		labelRect = CGRectMake(width * 2, height * 2, width, height);
				UILabel*	label = [self buildTextLabelWithFrame:labelRect];
				label.backgroundColor = [UIColor clearColor];
				[imageView addSubview:label];
			}			
		}

		float	cornerRadius = [brand globalFloat:@"skin/props/piece-corner-radius" withDefaultValue:0.0];
		if ( cornerRadius > 0 )
			contentView.layer.cornerRadius = (cornerRadius * MIN(frame.size.width, frame.size.height));
		
		UIImage*		overlayImage = nil;
		if ( customOverlays )
			overlayImage = [brand globalImage:[NSString stringWithFormat:@"piece-custom-overlay-%d", 
												(colorIndex + customColorsOffset) % [colorTable count]]
							  withDefaultValue:NULL];
		
		if ( !overlayImage )
			overlayImage = [brand globalImage:@"piece-overlay" withDefaultValue:NULL];
		if ( overlayImage )
		{
			UIImageView*	shineMask = [[[UIImageView alloc] initWithFrame:frame] autorelease];
			shineMask.image = overlayImage;
			shineMask.contentMode = UIViewContentModeScaleToFill;
			shineMask.layer.masksToBounds = YES;
			if ( cornerRadius > 0.0 )
				shineMask.layer.cornerRadius = contentView.layer.cornerRadius;
			[contentView addSubview:shineMask];			
		}
					
		contentView.layer.masksToBounds = YES;
		
		// build image
		UIImage*		cImage = [UIImage imageWithView:contentView scaledToSize:frame.size];
		
		UIImage*		maskImage = nil;
		if ( customMasks )
			maskImage = [brand globalImage:[NSString stringWithFormat:@"piece-custom-mask-%d", 
													(colorIndex + customColorsOffset) % [colorTable count]]
													 withDefaultValue:NULL];
		if ( !maskImage )
			maskImage = [brand globalImage:@"piece-mask" withDefaultValue:NULL];
		if ( maskImage )
			cImage = [cImage imageWithMask:maskImage];
		
		contentImage = [[[ImageWithUUID alloc] initWithCGImage:cImage.CGImage] autorelease];
		contentImage.uuid = [UUIDUtils createUUID];
		contentImage.lastTimeUsed = time(NULL);
		if ( imageKey )
		{
			[[SymbolPieceView imageDict] setObject:contentImage forKey:imageKey];
			contentImage.key = imageKey;
		}
		
#ifdef	MEASURE
		NSLog(@"[SymbolPieceView] %f buildContentView %@", (float)(clock() - startedAt) / CLOCKS_PER_SEC, imageKey);
#endif
		
		//NSLog(@"contentImage: %@ %f", contentImage, contentImage.size.width);
		
#if WRITE_IMAGES && TARGET_IPHONE_SIMULATOR
		// write to temp file ...
		NSData*					imageData = UIImagePNGRepresentation(contentImage);
		NSString*				path = [[Folders temporaryFolder] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.png", [_model text]]];
		
		NSLog(@"writing %@ ...", path);
		[imageData writeToFile:path atomically:FALSE];
#endif
		
	}
	
	
	UIImageView* renderedContentView = [[[UIImageView alloc] initWithFrame:self.frame] autorelease];
	renderedContentView.image = contentImage;
	
	return renderedContentView;
}

-(UILabel*)buildTextLabelWithFrame:(CGRect)frame
{
	UILabel*		label = [[[UILabel alloc] initWithFrame:frame] autorelease];
	NSString*		text = [_model text];
	
	if ( [text hasSuffix:@"/"] )
		text = [[text componentsSeparatedByString:@"/"] objectAtIndex:0];
	
	[label setBackgroundColor:[self getColorForIndex:colorIndex]];
	label.text = text;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [[BrandManager currentBrand] globalDefaultFont:8 * frame.size.height / 10 bold:TRUE];
	label.textColor = [self getTextColorForIndex:colorIndex];
	
	return label;
}

+(NSMutableDictionary*)imageDict
{
	NSMutableDictionary*	dict = [globalData objectForKey:IMAGES_KEY];
	
	if ( !dict )
		[globalData setObject:(dict = [NSMutableDictionary dictionary]) forKey:IMAGES_KEY];
	
	return dict;
}

-(void)clearImageDict
{
	[[SymbolPieceView imageDict] removeAllObjects];
}

-(NSString*)imageDictKey:(BOOL)fadeMask;
{
	CGSize		size = self.frame.size;
	
	// start with fixed part
	NSMutableString*	key;
	if ( !fadeMask )
		key = [NSMutableString stringWithFormat:@"%@-%f-%f", [_model text], size.width, size.height];
	else
		key = [NSMutableString stringWithFormat:@"F-%d-%f-%f", [SymbolPieceView getStringIndex:[_model text]], size.width, size.height];
	
	if ( fadeMask )
		return key;
	
	// has image?
	UIImage*			image = [_model image];
	if ( !image )
		return key;
	
	// image has semi-permanent id?
	if ( ![image respondsToSelector:@selector(uuid)] )
		return nil;
	
	// append uuid to key
	[key appendFormat:@"-%@", [image performSelector:@selector(uuid)]];

	return key;
}

static NSInteger guardImageDictSizeSortFunction(id a, id b, void* context)
{
	time_t		ta = ((ImageWithUUID*)a).lastTimeUsed;
	time_t		tb = ((ImageWithUUID*)b).lastTimeUsed;
	
	if ( ta < tb )
		return NSOrderedAscending;
	else if ( ta > tb )
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

+(void)guardImageDictSize:(BOOL)inGame
{
	NSMutableDictionary*	dict = [SymbolPieceView imageDict];
	if ( [dict count] >= (inGame ? IMAGES_HIGH_THRESHOLD_INGAME : IMAGES_HIGH_THRESHOLD) )
	{
		//NSLog(@"guardImageDictSize: reducing to low threshold");
		
		// reduce map back to low threshold
		NSMutableArray*		images = [NSMutableArray arrayWithArray:[dict allValues]];
		[images sortUsingFunction:guardImageDictSizeSortFunction context:nil];
		for ( ImageWithUUID* image in images )
		{
			if ( [dict count] <= IMAGES_LOW_THRESHOLD )
				break;
			//NSLog(@"guardImageDictSize: removing %@", image.key);
			[dict removeObjectForKey:image.key];
		}
	}
}

@end
