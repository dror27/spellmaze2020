//
//  JokerUtils.m
//  Board3
//
//  Created by Dror Kessler on 9/5/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "JokerUtils.h"

#define	JOKER_IMAGE			@"ProgramIcon1.png"
#define	JOKER_PROB			0.0
#define	JOKER_CHAR			'?'
#define	MAX_JOKERS_IN_WORD	2

extern NSMutableDictionary*	globalData;

@implementation JokerUtils

+(UIImage*)jokerImage
{
	return NULL;
	
	if ( ![globalData objectForKey:@"JokerUtils_image"] )
	{
		[globalData setObject:[UIImage imageNamed:JOKER_IMAGE] forKey:@"JokerUtils_image"];
	}
	
	return [globalData objectForKey:@"JokerUtils_image"];
}

+(float)globalJokerProb
{
	return JOKER_PROB;
}

+(unichar)jokerCharacter
{
	return JOKER_CHAR;
}

+(int)maxJokersInWord
{
	return MAX_JOKERS_IN_WORD;
}

+(BOOL)containsJoker:(NSString*)word
{	
	// TODO: there must be an easier way of doing that ...
	int			length = [word length];
	unichar*	chars = alloca(sizeof(unichar) * length);
	unichar		joker = [JokerUtils jokerCharacter];
	
	[word getCharacters:chars];
	for ( int ofs = 0 ; ofs < length ; ofs++ )
		if ( chars[ofs] == joker )
			return TRUE;
	
	return FALSE;
}

+(BOOL)pieceIsJoker:(id<Piece>)piece
{
	NSString*	s = [piece text];

	if ( [s length] == 1 && [s characterAtIndex:0] == JOKER_CHAR )
		return TRUE;
	else
		return FALSE;
}

@end
