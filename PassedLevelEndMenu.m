//
//  PassedLevelEndMenu.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PassedLevelEndMenu.h"
#import "Gamelevel.h"
#import "GameLevelSequence.h"
#import "L.h"

@implementation PassedLevelEndMenu
@synthesize level = _level;
@synthesize seq = _seq;
@synthesize actionSheet = _actionSheet;
@synthesize buttonContextCodes = _buttonContextCodes;

-(id)initWithGameLevel:(GameLevel*)level andGameLevelSequence:(GameLevelSequence*)seq
{
	if ( (self = [super init]) )
	{
		self.level = level;
		self.seq = seq;
		
		int				totalWords = [_level languageWordCount];
		int				doneWords = [_level validSelectedWordCount];
		int				remainingWords = totalWords - doneWords;
		
		/*
		NSMutableString*		title = [NSMutableString stringWithString:LOC(@"Level Passed")];
		[title appendString:@"\n\n"];
		*/
		NSMutableString*		title = [NSMutableString string];
		if ( remainingWords )
			[title appendFormat:@"Completed %d of %d possible words", doneWords, totalWords];
		else
			[title appendFormat:@"Completed all %d possible words", totalWords];
		
		NSMutableArray*		buttonContextCodes = [NSMutableArray array];
		NSMutableArray*		buttonTexts = [NSMutableArray array];

		[buttonTexts addObject:LOC(@"Move To Next Level")];
		[buttonContextCodes addObject:[NSNumber numberWithInt:PassedLevelEndMenuContext_NextLevel]];
		
		if ( remainingWords > _level.levelEndContinueRemainingWordCountThreshold )
		{
			[buttonTexts addObject:[NSString stringWithFormat:LOC(@"Play Remaining Words"), remainingWords]];
			[buttonContextCodes addObject:[NSNumber numberWithInt:PassedLevelEndMenuContext_ContinueLevel]];
		}
	
		/*
		[buttonTexts addObject:LOC(@"Restart Level")];
		[buttonContextCodes addObject:[NSNumber numberWithInt:PassedLevelEndMenuContext_RepeatLevel]];
		*/
		 
		/*
		[buttonTexts addObject:LOC(@"Stop Playing")];
		[buttonContextCodes addObject:[NSNumber numberWithInt:PassedLevelEndMenuContext_StopPlaying]];
		 */
		
		self.buttonContextCodes = buttonContextCodes;
		
        self.actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        int     buttonIndex = (int)[buttonTexts count] - 1;
        for ( NSString* buttonText in buttonTexts ) {
            
            [_actionSheet addAction:[UIAlertAction actionWithTitle:buttonText style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self actionSheetButton:buttonIndex];
            }]];
            
            buttonIndex--;
        }
	}
	return self;
}

-(void)dealloc
{
	[_level release];
    [_actionSheet release];
	[super dealloc];
}

-(void)show
{
    [self.level.view.window.rootViewController presentViewController:_actionSheet animated:YES completion:nil];
}

-(void)actionSheetButton:(NSInteger)buttonIndex
{
	NSNumber*		code = [_buttonContextCodes objectAtIndex:buttonIndex];
	
	[_seq passedLevel:_level withMessage:nil andContext:(void*)[code intValue]];
}



@end
