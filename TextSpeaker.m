//
//  TextSpeaker.m
//  Board3
//
//  Created by Dror Kessler on 6/16/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "TextSpeaker.h"
#include <AudioToolbox/AudioToolbox.h>
#import "speak_lib.h"
#import "UserPrefs.h"
#import "SystemUtils.h"

static int SynthCallback(short *wav, int numsamples, espeak_EVENT *events);
static int OpenWavFile(const char *path, int rate);
static void CloseWavFile();

static BOOL	TextSpeaker_initialized = FALSE;
static int	TextSpeaker_samplerate = 0;
static FILE *TextSpeaker_f_wavfile = NULL;
static NSString *TextSpeaker_default_voice = NULL;
static NSString *TextSpeaker_current_voice = NULL;

@interface TextSpeaker (Privates)
+(void)init;
+(BOOL)langIsCertified:(NSString*)lang;
+(void)switchToLang:(NSString*)lang;
+(NSString*)extendedVoiceName:(NSString*)voiceName;
@end


@implementation TextSpeaker
@synthesize player = _player;

static NSString*	initLock = @"INIT_LOCK";
static NSString*	speakLock = @"SPEAK_LOCK";
static BOOL			speakAbort = FALSE;

-(void)dealloc
{

	[_player release];
	
	[super dealloc];
}

+(BOOL)enabled
{
	return [UserPrefs getBoolean:@"pref_tts_enabled" withDefault:TRUE];
}

+(BOOL)speak:(NSString*)text
{
	[TextSpeaker init];
	
	NSString*		realText = NULL;
	if ( [text isKindOfClass:[NSString class]] )
		realText = text;
	else if ( [text isKindOfClass:[NSArray class]] )
		realText = [((NSArray*)text) objectAtIndex:0];
	
	if ( [TextSpeaker enabled] && [realText cStringUsingEncoding:[NSString defaultCStringEncoding]] )
	{
		TextSpeaker*		speaker = [[[TextSpeaker alloc] init] autorelease];
		
		[SystemUtils threadWithTarget:speaker selector:@selector(speakerThread:) object:text];
		//[NSThread detachNewThreadSelector:@selector(speakerThread:) toTarget:speaker withObject:text];
		return TRUE;
	}
	else 
		return FALSE;
}

+(BOOL)play:(NSURL*)url
{
	[TextSpeaker init];
	
	if ( [TextSpeaker enabled] )
	{
		TextSpeaker*		speaker = [[[TextSpeaker alloc] init] autorelease];
		
		[SystemUtils threadWithTarget:speaker selector:@selector(speakerThread:) object:url];
		//[NSThread detachNewThreadSelector:@selector(speakerThread:) toTarget:speaker withObject:url];
		return TRUE;
	}
	else 
		return FALSE;
}

-(BOOL)speak:(NSString*)text
{
	return [TextSpeaker speak:text];
}

+(void)init
{
	// initialize?
	@synchronized(initLock)
	{
		if ( !TextSpeaker_initialized )
		{
			if ( TRUE ) // always initialize
			{
				// figure out default voice from locale
				NSArray*	preferredLanguages = [NSLocale preferredLanguages];
				if ( [preferredLanguages count] > 0 )
				{
					NSString*		lang = [preferredLanguages objectAtIndex:0];
					
					if ( [TextSpeaker langIsCertified:lang] )
						TextSpeaker_default_voice = [lang retain];
				}
				if ( !TextSpeaker_default_voice )
					TextSpeaker_default_voice = [TEXTSPEAKER_VOICE_DEFAULT retain];
				TextSpeaker_current_voice = [[self extendedVoiceName:TextSpeaker_default_voice] retain];
				
				//NSLog(@"TextSpeaker_default_voice: %@", TextSpeaker_default_voice);
				
				
				NSString*	resourcesPath = [[NSBundle mainBundle] resourcePath];
				//NSLog(@"resourcesPath: %@", resourcesPath);
				const char*	data_path = [resourcesPath cStringUsingEncoding:[NSString defaultCStringEncoding]];
				
				TextSpeaker_samplerate = espeak_Initialize(AUDIO_OUTPUT_SYNCHRONOUS,0,data_path,0);
				espeak_SetSynthCallback(SynthCallback);
				//NSLog(@"TextSpeaker_current_voice: %@", TextSpeaker_current_voice);
				espeak_SetVoiceByName([TextSpeaker_current_voice UTF8String]);
				
				[UserPrefs addKeyDelegate:[[TextSpeaker alloc] init] forKey:@"pref_voice_suffix"];
			}
			
			TextSpeaker_initialized = TRUE;
		}
	}	
}

-(void)speakerThread:(id)param;
{
	NSAutoreleasePool*		pool = [[NSAutoreleasePool alloc] init];
	
	NSString*				text = [param isKindOfClass:[NSString class]] ? param : NULL;
	NSURL*					url = [param isKindOfClass:[NSURL class]] ? param : NULL;
	NSString*				lang = NULL;
	
	if ( [param isKindOfClass:[NSArray class]] )
	{
		NSArray*	array = param;
		
		text = [array objectAtIndex:0];
		if ( [array count] > 1 )
			lang = [array objectAtIndex:1];
	}
	if ( [text hasPrefix:@"-- "] )
		text = [text substringFromIndex:3];
	else
		speakAbort = TRUE;
	@synchronized(speakLock)
	{
		speakAbort = FALSE;
		if ( text )
		{
			// switch to lang
			[TextSpeaker switchToLang:lang];
			
			if ( !speakAbort )
			{
				// speak into a wav file
				NSString*	outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"espeak_out.wav"];
				//NSLog(@"outputPath: %@", outputPath);
				
				int			synth_flags = espeakCHARS_AUTO | espeakPHONEMES | espeakENDPAUSE;
				const char*	p_text = [text cStringUsingEncoding:[NSString defaultCStringEncoding]];
				if ( p_text && !speakAbort )
				{
					int			size = strlen(p_text);
					
					OpenWavFile([outputPath cStringUsingEncoding:[NSString defaultCStringEncoding]], TextSpeaker_samplerate); 
					espeak_Synth(p_text,size+1,0,POS_CHARACTER,0,synth_flags,NULL,NULL);
					espeak_Synchronize();
				}
				url = [[[NSURL alloc] initFileURLWithPath:outputPath isDirectory:FALSE] autorelease];
			}
		}
		
		if ( url )
		{
			if ( !speakAbort )
			{
				self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL] autorelease];
				//NSLog(@"player.volume: %f", _player.volume);
				[_player play];
				while ( [_player isPlaying] )
					if ( !speakAbort )
						sleep(1);
					else
					{
						[_player stop];
						break;
					}
			}
		}
	}
	
	[pool release];
}

static void Write4Bytes(FILE *f, int value)
{//=================================
	// Write 4 bytes to a file, least significant first
	int ix;
	
	for(ix=0; ix<4; ix++)
	{
		fputc(value & 0xff,f);
		value = value >> 8;
	}
}



static int OpenWavFile(const char *path, int rate)
//===================================
{
	static unsigned char wave_hdr[44] = {
		'R','I','F','F',0x24,0xf0,0xff,0x7f,'W','A','V','E','f','m','t',' ',
		0x10,0,0,0,1,0,1,0,  9,0x3d,0,0,0x12,0x7a,0,0,
	2,0,0x10,0,'d','a','t','a',  0x00,0xf0,0xff,0x7f};
	
	if(path == NULL)
		return(2);
	
	if(path[0] == 0)
		return(0);
	
	if(strcmp(path,"stdout")==0)
		TextSpeaker_f_wavfile = stdout;
	else
		TextSpeaker_f_wavfile = fopen(path,"wb");
	
	if(TextSpeaker_f_wavfile != NULL)
	{
		fwrite(wave_hdr,1,24,TextSpeaker_f_wavfile);
		Write4Bytes(TextSpeaker_f_wavfile,rate);
		Write4Bytes(TextSpeaker_f_wavfile,rate * 2);
		fwrite(&wave_hdr[32],1,12,TextSpeaker_f_wavfile);
		return(0);
	}
	return(1);
}   //  end of OpenWavFile


static void CloseWavFile()
//========================
{
	unsigned int pos;
	
	if((TextSpeaker_f_wavfile==NULL) || (TextSpeaker_f_wavfile == stdout))
		return;
	
	fflush(TextSpeaker_f_wavfile);
	pos = ftell(TextSpeaker_f_wavfile);
	
	fseek(TextSpeaker_f_wavfile,4,SEEK_SET);
	Write4Bytes(TextSpeaker_f_wavfile,pos - 8);
	
	fseek(TextSpeaker_f_wavfile,40,SEEK_SET);
	Write4Bytes(TextSpeaker_f_wavfile,pos - 44);
	
	fclose(TextSpeaker_f_wavfile);
	TextSpeaker_f_wavfile = NULL;
	
} // end of CloseWavFile


static int SynthCallback(short *wav, int numsamples, espeak_EVENT *events)
{//========================================================================
	if(wav == NULL)
	{
		CloseWavFile();
		return(0);
	}
	
	if(numsamples > 0)
	{
		fwrite(wav,numsamples*2,1,TextSpeaker_f_wavfile);
	}
	return(0);
}


+(BOOL)langIsCertified:(NSString*)lang
{
	NSArray*	cert = [@"af,bs,cs,de,el,eo,es,es-la,fi,fr,hr,hu,it,ku,lv,pl,pt,pt-pt,ro,sk,sr,sv,sw,ta,tr,zh,en,en-us,en-sc,default"
						componentsSeparatedByString:@","];
	
	return [cert containsObject:lang];
}

+(void)switchToLang:(NSString*)lang
{
	if ( !lang )
		lang = TextSpeaker_default_voice;
	
	NSString*	extLang = [self extendedVoiceName:lang];
	
	if ( ![extLang isEqualToString:TextSpeaker_current_voice] )
	{
		if ( ![TextSpeaker langIsCertified:lang] )
			extLang = [self extendedVoiceName:TextSpeaker_default_voice];
		
		[TextSpeaker_current_voice autorelease];
		TextSpeaker_current_voice = [extLang retain];
		
		NSLog(@"extLang: %@", extLang);
		
		espeak_SetVoiceByName([extLang UTF8String]);
	}	
}

+(NSString*)extendedVoiceName:(NSString*)voiceName
{
	return [voiceName stringByAppendingString:[UserPrefs getString:@"pref_voice_suffix" withDefault:@""]];
}

-(void)userPrefsKeyChanged:(NSString*)key
{
	[TextSpeaker speak:@"This is my new voice! Do you like it?"];
}
@end
