//
//  ImageSequenceMediaView.h
//  SpellMaze
//
//  Created by Dror Kessler on 11/5/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef enum
{
	ImageSequenceMediaViewStateLoading,
	ImageSequenceMediaViewStateReady,
	ImageSequenceMediaViewStatePlaying
} ImageSequenceMediaViewState;


@interface ImageSequenceMediaView : UIView {

	UIImageView*					_imageView;	
	NSDictionary*					_props;
	UIImage*						_posterImage;
	NSString*						_folder;
	ImageSequenceMediaViewState		state;
	BOOL							playPending;
	UIActivityIndicatorView*		_loadingView;
	
	AVAudioPlayer*					_player;

}
@property (retain) UIImageView* imageView;
@property (retain) NSDictionary* props;
@property (retain) UIImage* posterImage;
@property (retain) NSString* folder;
@property ImageSequenceMediaViewState state;
@property (retain) UIActivityIndicatorView* loadingView;
@property (retain) AVAudioPlayer* player;

-(id)initWithFrame:(CGRect)frame andFolder:(NSString*)folder andProps:(NSDictionary*)props;
-(void)play;
-(void)stop;

@end
