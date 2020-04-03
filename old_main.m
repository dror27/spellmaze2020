//
//  main.m
//  Board3
//
//  Created by Dror Kessler on 4/29/09.
//  Copyright Dror Kessler (M-1) 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JIM_EMBEDDED
#include "jim.h"
#import "JIMInterp.h"
#import "TextSpeaker.h"
#import "UserPrefs.h"
#import "UIDevice_AvailableMemory.h"
#import "ScreenDumper.h"
#import "StoreManager.h"

int espeak_main(int argc, char **argv);

NSMutableDictionary*	globalData;

#define OLD_MAIN    1
#ifdef OLD_MAIN
int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//NSLog(@"main: available memory: %g", [UIDevice currentDevice].availableMemory);
	//NSLog(@"device: %@", [[UIDevice currentDevice] identifierForVendor]);

	
	globalData = [[[NSMutableDictionary alloc] init] autorelease];
	[UserPrefs init];
	srand(time(NULL));
	
#if 0
	{
		for ( NSString* path in [NSArray arrayWithObjects:@"/tmp/words.txt", 
											@"/tmp/words_head.txt", @"/tmp/words_tail.txt", NULL] )
		{
			NSError		*error;
			NSString	*strings = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
			if ( !strings )
			{
				NSLog(@"%@ - ERROR: %@", path, error);
				
				NSData*			data = [NSData dataWithContentsOfFile:path];
				NSLog(@"data length: %d", [data length]);
				int				length = [data length];
				const unsigned char*	bytes = [data bytes];
				for ( int n = 0 ; n < length ; n++ )
				{
					unsigned char		ch = bytes[n];
					
					if ( ch > 127 )
					{
						NSLog(@"ch at %d is %d", n, ch);
						
						char			s[256];
						memcpy(s, bytes + n - 32, 64);
						s[64] = '\0';
						NSLog(@"s: %s", s);
					}
				}
				
			}
			else
				NSLog(@"%@ - OK", path);			

		}
	}
	
#endif
	
#if SCRIPTING
	// init Jim
	Jim_InitEmbedded();
#endif

#if 0
	// create some UUIDs
	for ( int n = 0 ; n < 10 ; n++ )
	{
		CFUUIDRef	uuidRef = CFUUIDCreate(NULL);
		CFStringRef	strRef = CFUUIDCreateString(NULL, uuidRef);
		NSLog(@"UUID: %@", strRef);
		CFRelease(strRef);
		CFRelease(uuidRef);
	}
#endif
	
#if 0
	{
		// toupper ...
		for ( NSString* s in [NSArray arrayWithObjects: @"Волк", @"слов", @"Да", @"слов", NULL] ) 
			NSLog(@"toupper: %@ - %@", s, [s uppercaseString]);
	}
#endif
	
#if 0
	// dump font names
	{
		for ( NSString* familyName in [UIFont familyNames] )
		{
			//NSLog(@"familyName: %@", familyName);
			
			for ( NSString* fontName in [UIFont fontNamesForFamilyName:familyName] )
			{
				//NSLog(@"---- fontName: %@", fontName);
				printf("%s\n", [fontName UTF8String]);
			}
		}
	}
#endif
	
#if 0
	// create some images
	UIImage*		image = [UIImage imageNamed:@"2.0.png"];
	NSData*			imageData = UIImageJPEGRepresentation(image, 0.8);
	NSLog(@"image data size: %d", [imageData length]);
	int				length = [imageData length];
	const unsigned char*	bytes = [imageData bytes];
	char					*imageString = alloca(length * 2 + 1);
	char					*p = imageString;
	while ( length-- )
	{
		unsigned char	ch = *bytes++;
		
		*p++ = "0123456789ABCDEF"[(ch >> 4) & 0xF];
		*p++ = "0123456789ABCDEF"[ch & 0xF];
	}
	*p = '\0';
	NSLog(@"imageString: %s", imageString);
#endif	
	
	
#if 0
	// test espeak
	const char*	resourcesPath = [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:[NSString defaultCStringEncoding]];
	NSLog(@"resourcesPath: %s", resourcesPath);
	const char* outputPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"espeak_out.wav"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
	NSLog(@"outputPath: %s", outputPath);
	
	const char	*espeak_argv[] = {argv[0], "-w", outputPath, "--path", resourcesPath, "Testing 1 2 3", NULL};
	espeak_main(6, (char**)espeak_argv);
#endif
	
#if 1
	[[[[TextSpeaker alloc] init] autorelease] performSelector:@selector(speak:) 
								withObject:[NSArray arrayWithObjects:@"Welcome to Spell Maze 2020", @"en", NULL] 
												   afterDelay:1.0];
#endif
    
#if 0 && SCRIPTING
	// test Jim
	JIMInterp*	interp = [[JIMInterp alloc] init];
		
	// simple tcl stuff
	NSLog(@"result: %@", [interp eval:@"set i 3"]);
	
	// class methods (no args)
	NSLog(@"result: %@", [interp eval:@"JimTestClass classMethod_Returns_Id"]);
	NSLog(@"result: %@", [interp eval:@"JimTestClass classMethod_Returns_NSString"]);
	NSLog(@"result: %@", [interp eval:@"JimTestClass classMethod_Returns_Int"]);
	NSLog(@"result: %@", [interp eval:@"JimTestClass classMethod_Returns_Float"]);

	// instance methods (no args)
	NSLog(@"result: %@", [interp eval:@"[JimTestClass alloc] instanceMethod_Returns_Id"]);
	NSLog(@"result: %@", [interp eval:@"[JimTestClass alloc] instanceMethod_Returns_NSString"]);
	NSLog(@"result: %@", [interp eval:@"[JimTestClass alloc] instanceMethod_Returns_Int"]);
	NSLog(@"result: %@", [interp eval:@"[JimTestClass alloc] instanceMethod_Returns_Float"]);

	// instance method (w/ args)
	NSLog(@"result: %@", [interp eval:@"[JimTestClass alloc] instanceMethod_Returns_Int_Add:with: 1 2"]);
#endif
	
	int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    [pool release];
    return retVal;
}
#endif
