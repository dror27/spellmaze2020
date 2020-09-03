//
//  PieceFaderGBL.m
//  Board3
//
//  Created by Dror Kessler on 5/25/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "PieceFaderGBL.h"
#import	"GameLevel.h"


@implementation PieceFaderGBL

@synthesize fadePace;
@synthesize resetFadeOnValidWord;

-(void)pieceDispensed:(id<Piece>)piece
{
	[self initFade:piece];
}

-(void)validWordSelected:(NSString*)word
{
	if ( resetFadeOnValidWord )
		[self resetFade];
}

-(void)onGameTimer
{
	[self incrementFade];
}

-(void)initFade:(id<Piece>)piece
{
	time_t			now = time(NULL);
	NSData*			data = [NSData dataWithBytes:&now length:sizeof(now)];
	[[piece props] setObject:data forKey:@"dispensed_at"];	
	
	[piece setFade:0];
}

-(void)resetFade
{
	for ( id<Piece> piece in [_board allPieces] )
	{
		[self initFade:piece];
	}
}

-(void)incrementFade
{
	if ( fadePace <= 0 )
		return;
	
	time_t		now = time(NULL);
	time_t		dispensed_at;
	for ( id<Piece> piece in [_board allPieces] )
	{
		NSData*		data = [[piece props] objectForKey:@"dispensed_at"];
		if ( data )
		{
			[data getBytes:&dispensed_at];
			
			float	pace = (fadePace >= 500) ? fadePace : (fadePace * 1000);
			
			float	fadeLevel = (float)(now - dispensed_at) / pace * 1000;
			if ( fadeLevel > 1.0 )
				fadeLevel = 1.0;
			
			[piece setFade:fadeLevel];
		}
	}
}

-(NSString*)role
{
	return @"Effect";
}

@end
