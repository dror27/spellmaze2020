//
//  SoundTheme.h
//  Board3
//
//  Created by Dror Kessler on 5/16/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>
#import "Language.h"

@interface SoundTheme : NSObject {

	NSMutableDictionary*	_sounds;
	NSMutableSet*			_notFound;
	
	BOOL					speakValidWords;
	
	BOOL					enabled;
		
}
@property (retain) NSMutableDictionary* sounds;
@property (retain) NSMutableSet* notFound;
@property BOOL speakValidWords;
@property (readonly) BOOL enabled;

-(void)pieceSelected;
-(void)pieceDispensed;
-(void)wordValid:(NSString*)word fromLanguage:(id<Language>)language;
-(void)wordInvalid;
-(void)wordBlackListed;
-(void)wordReset;
-(void)pieceHinted;
-(void)pieceHintedLast;

-(void)clicked;
-(void)swiped;

-(void)boardFullWarning;
-(void)dispenserDoneWarning;
-(void)passedLevel;
-(void)failedLevel;

-(void)decoration:(NSString*)decoration;
-(void)decorationExtra:(NSString*)decoration;

-(void)addSound:(NSString*)name;

+(SoundTheme*)singleton;

@end
