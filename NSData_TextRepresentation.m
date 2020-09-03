//
//  NSData_TextRepresentation.m
//  SpellMaze
//
//  Created by Dror Kessler on 11/2/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import "NSData_TextRepresentation.h"


@implementation NSData (TextRepresentation)

-(NSString*)textRepresentation
{
	int						length = [self length];
	const unsigned char*	bytes = [self bytes];
	char					*imageString = alloca(length * 2 + 1);
	char					*p = imageString;
	while ( length-- )
	{
		unsigned char	ch = *bytes++;
		
		*p++ = "0123456789ABCDEF"[(ch >> 4) & 0xF];
		*p++ = "0123456789ABCDEF"[ch & 0xF];
	}
	*p = '\0';
	
	return [NSString stringWithCString:imageString encoding:NSUTF8StringEncoding];
}

+(NSData*)dataFromTextRepresentation:(NSString*)textRepresentation
{
	if ( !textRepresentation )
		return NULL;
	
	int				length = [textRepresentation length];
	unsigned char*	bytes = alloca(length / 2), *outp = bytes;;
	const char*		chars = [textRepresentation cStringUsingEncoding:NSUTF8StringEncoding], *inp = chars;
	length /= 2;
	for ( int n = 0 ; n < length ; n++ )
	{
		char				outbyte = 0;
		
		unsigned char		inch = *inp++;
		if ( inch >= '0' && inch <= '9' )
			outbyte = inch - '0';
		else if ( inch >= 'A' && inch <= 'F' )
			outbyte = inch - 'A' + 10;
		outbyte <<= 4;
		
		inch = *inp++;
		if ( inch >= '0' && inch <= '9' )
			outbyte |= inch - '0';
		else if ( inch >= 'A' && inch <= 'F' )
			outbyte |= inch - 'A' + 10;
		
		*outp++ = outbyte;
	}
	
	return [NSData dataWithBytes:bytes length:length];
}



@end
