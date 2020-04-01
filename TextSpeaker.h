//
//  TextSpeaker.h
//  Board3
//
//  Created by Dror Kessler on 6/16/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UserPrefs.h"

#define	TEXTSPEAKER_VOICE_DEFAULT		@"default"
#define	TEXTSPEAKER_VOICE_DEFAULT_LANG	@"en"



@interface TextSpeaker : NSObject<UserPrefsDelegate> {

	AVAudioPlayer*		_player;
	
}
@property (retain) AVAudioPlayer* player;

+(BOOL)speak:(NSString*)text;
+(BOOL)play:(NSURL*)url;
+(BOOL)enabled;

-(BOOL)speak:(NSString*)text;


@end

