/***************************************************************************
 *   Copyright (C) 2006 to 2007 by Jonathan Duddington                     *
 *   email: jonsd@users.sourceforge.net                                    *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write see:                           *
 *               <http://www.gnu.org/licenses/>.                           *
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include <time.h>
#include <sys/stat.h>

#include "speak_lib.h"

// This version of the command-line speak program uses the
// libespeak.so.1  library



static const char *help_text =
"\nspeak [options] [\"<words>\"]\n\n"
"-f <text file>   Text file to speak\n"
"--stdin    Read text input from stdin instead of a file\n\n"
"If neither -f nor --stdin, <words> are spoken, or if none then text is\n"
"spoken from stdin, each line separately.\n\n"
"-a <integer>\n"
"\t   Amplitude, 0 to 200, default is 100\n"
"-g <integer>\n"
"\t   Word gap. Pause between words, units of 10mS at the default speed\n"
"-l <integer>\n"
"\t   Line length. If not zero (which is the default), consider\n"
"\t   lines less than this length as end-of-clause\n"
"-p <integer>\n"
"\t   Pitch adjustment, 0 to 99, default is 50\n"
"-s <integer>\n"
"\t   Speed in words per minute, 80 to 390, default is 170\n"
"-v <voice name>\n"
"\t   Use voice file of this name from espeak-data/voices\n"
"-w <wave file name>\n"
"\t   Write output to this WAV file, rather than speaking it directly\n"
"-b\t   Input text is 8-bit encoding\n"
"-m\t   Interpret SSML markup, and ignore other < > tags\n"
"-q\t   Quiet, don't produce any speech (may be useful with -x)\n"
"-x\t   Write phoneme mnemonics to stdout\n"
"-X\t   Write phonemes mnemonics and translation trace to stdout\n"
"-z\t   No final sentence pause at the end of the text\n"
"--stdout   Write speech output to stdout\n"
"--compile=<voice name>\n"
"\t   Compile the pronunciation rules and dictionary in the current\n"
"\t   directory. =<voice name> is optional and specifies which language\n"
"--path=\"<path>\"\n"
"\t   Specifies the directory containing the espeak-data directory\n"
"--phonout=\"<filename>\"\n"
"\t   Write output from -x -X commands and mbrola phoneme data to this file\n"
"--punct=\"<characters>\"\n"
"\t   Speak the names of punctuation characters during speaking.  If\n"
"\t   =<characters> is omitted, all punctuation is spoken.\n"
"--split=\"<minutes>\"\n"
"\t   Starts a new WAV file every <minutes>.  Used with -w\n"
"--voices=<language>\n"
"\t   List the available voices for the specified language.\n"
"\t   If <language> is omitted, then list all voices.\n"
"-k <integer>\n"
"\t   Indicate capital letters with: 1=sound, 2=the word \"capitals\",\n"
"\t   higher values = a pitch increase (try -k20).\n";




static int samplerate;
static int quiet = 0;
unsigned int samples_total = 0;
unsigned int samples_split = 0;
unsigned int wavefile_count = 0;

FILE *f_wavfile = NULL;
char filetype[5];
char wavefile[200];


static int GetFileLength(const char *filename)
{//====================================
	struct stat statbuf;

	if(stat(filename,&statbuf) != 0)
		return(0);

	if((statbuf.st_mode & S_IFMT) == S_IFDIR)
		return(-2);  // a directory

	return(statbuf.st_size);
}  // end of GetFileLength


static void strncpy0(char *dest, const char *source, int size)
{//====================================================
	if(source!=NULL)
	{
		strncpy(dest,source,size);
		dest[size-1] = 0;
	}
}


void DisplayVoices(FILE *f_out, char *language)
{//============================================
	int ix;
	const char *p;
	int len;
	int count;
	int scores = 0;
	const espeak_VOICE *v;
	const char *lang_name;
	char age_buf[12];
	const espeak_VOICE **voices;
	espeak_VOICE voice_select;

	static char genders[4] = {' ','M','F',' '};

	if((language != NULL) && (language[0] != 0))
	{
		// display only voices for the specified language, in order of priority
		voice_select.languages = language;
		voice_select.age = 0;
		voice_select.gender = 0;
		voice_select.name = NULL;
		voices = espeak_ListVoices(&voice_select);
		scores = 1;
	}
	else
	{
		voices = espeak_ListVoices(NULL);
	}

	fprintf(f_out,"Pty Language Age/Gender VoiceName       File        Other Langs\n");

	for(ix=0; (v = voices[ix]) != NULL; ix++)
	{
		count = 0;
		p = v->languages;
		while(*p != 0)
		{
			len = strlen(p+1);
			lang_name = p+1;

			if(v->age == 0)
				strcpy(age_buf,"   ");
			else
				sprintf(age_buf,"%3d",v->age);

			if(count==0)
			{
				fprintf(f_out,"%2d  %-12s%s%c  %-17s %-11s ",
               p[0],lang_name,age_buf,genders[v->gender],v->name,v->identifier);
			}
			else
			{
				fprintf(f_out,"(%s %d)",lang_name,p[0]);
			}
			count++;
			p += len+2;
		}
//		if(scores)
//			fprintf(f_out,"%3d  ",v->score);
		fputc('\n',f_out);
	}
}   //  end of DisplayVoices




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
		f_wavfile = stdout;
	else
		f_wavfile = fopen(path,"wb");

	if(f_wavfile != NULL)
	{
		fwrite(wave_hdr,1,24,f_wavfile);
		Write4Bytes(f_wavfile,rate);
		Write4Bytes(f_wavfile,rate * 2);
		fwrite(&wave_hdr[32],1,12,f_wavfile);
		return(0);
	}
	return(1);
}   //  end of OpenWavFile



static void CloseWavFile()
//========================
{
	unsigned int pos;

	if((f_wavfile==NULL) || (f_wavfile == stdout))
		return;

	fflush(f_wavfile);
	pos = ftell(f_wavfile);

	fseek(f_wavfile,4,SEEK_SET);
	Write4Bytes(f_wavfile,pos - 8);

	fseek(f_wavfile,40,SEEK_SET);
	Write4Bytes(f_wavfile,pos - 44);

	fclose(f_wavfile);
	f_wavfile = NULL;

} // end of CloseWavFile


static int SynthCallback(short *wav, int numsamples, espeak_EVENT *events)
{//========================================================================
	char fname[210];

	if(quiet) return(0);  // -q quiet mode

	if(wav == NULL)
	{
		CloseWavFile();
		return(0);
	}

	if(samples_split > 0)
	{
		// start a new WAV file when this limit is reached, at the next sentence boundary
		while(events->type != 0)
		{
			if((events->type == espeakEVENT_SENTENCE) && (samples_total > samples_split))
			{
				CloseWavFile();
				samples_total = 0;
			}
			events++;
		}
	}

	if(f_wavfile == NULL)
	{
		sprintf(fname,"%s_%.2d%s",wavefile,++wavefile_count,filetype);
		if(OpenWavFile(fname, samplerate) != 0)
			return(1);
	}

	if(numsamples > 0)
	{
		samples_total += numsamples;
		fwrite(wav,numsamples*2,1,f_wavfile);
	}
	return(0);
}


extern "C"
int espeak_main (int argc, char **argv)
//==============================
{
	static struct option long_options[] =
		{
		/* These options set a flag. */
//		{"verbose", no_argument,       &verbose_flag, 1},
//		{"brief",   no_argument,       &verbose_flag, 0},

		/* These options don't set a flag.
			We distinguish them by their indices. */
		{"help",    no_argument,       0, 'h'},
		{"stdin",   no_argument,       0, 0x100},
		{"compile-debug", optional_argument, 0, 0x101},
		{"compile", optional_argument, 0, 0x102},
		{"punct",   optional_argument, 0, 0x103},
		{"voices",  optional_argument, 0, 0x104},
		{"stdout",  no_argument,       0, 0x105},
		{"split",   optional_argument, 0, 0x106},
		{"path",    required_argument, 0, 0x107},
		{"phonout", required_argument, 0, 0x108}, 
		{0, 0, 0, 0}
		};

	static const char* err_load = "Failed to read ";


	FILE *f_text=NULL;
	char *p_text=NULL;
	FILE *f_phonemes_out = stdout;
	char *data_path = NULL;   // use default path for espeak-data

	int option_index = 0;
	int c;
	int ix;
	int flag_stdin = 0;
	int flag_compile = 0;
	int filesize = 0;
	int synth_flags = espeakCHARS_AUTO | espeakPHONEMES | espeakENDPAUSE;

	int volume = -1;
	int speed = -1;
	int pitch = -1;
	int wordgap = -1;
	int option_capitals = -1;
	int option_punctuation = -1;
	int option_phonemes = -1;
	int option_linelength = 0;
	int option_waveout = 0;

	espeak_VOICE voice_select;
	char filename[200];
	char voicename[40];
	char voice_mbrola[20];
	char dictname[40];
#define N_PUNCTLIST  100
	wchar_t option_punctlist[N_PUNCTLIST];

	voicename[0] = 0;
	voice_mbrola[0] = 0;
	dictname[0] = 0;
	wavefile[0] = 0;
	filename[0] = 0;
	option_punctlist[0] = 0;

	while(true)
	{
		c = getopt_long (argc, argv, "a:bf:g:hk:l:mp:qs:v:w:xXz",
					long_options, &option_index);

		/* Detect the end of the options. */
		if (c == -1)
			break;

		switch (c)
		{
		case 'b':
			synth_flags |= espeakCHARS_8BIT;
			break;

		case 'h':
			printf("\n");
			printf("eSpeak text-to-speech: %s\n%s",espeak_Info(NULL),help_text);
			exit(0);
			break;

		case 'k':
			option_capitals = atoi(optarg);
			break;

		case 'x':
			option_phonemes = 1;
			break;

		case 'X':
			option_phonemes = 2;
			break;

		case 'm':
			synth_flags |= espeakSSML;
			break;

		case 'p':
			pitch = atoi(optarg);
			break;

		case 'q':
			quiet = 1;
			break;

		case 'f':
			strncpy0(filename,optarg,sizeof(filename));
			break;

		case 'l':
			option_linelength = atoi(optarg);
			break;

		case 'a':
			volume = atoi(optarg);
			break;

		case 's':
			speed = atoi(optarg);
			break;

		case 'g':
			wordgap = atoi(optarg);
			break;

		case 'v':
			strncpy0(voicename,optarg,sizeof(voicename));
			break;

		case 'w':
			option_waveout = 1;
			strncpy0(wavefile,optarg,sizeof(filename));
			break;

		case 'z':  // remove pause from the end of a sentence
			synth_flags &= ~espeakENDPAUSE;
			break;

		case 0x100:		// --stdin
			flag_stdin = 1;
			break;

		case 0x105:		// --stdout
			option_waveout = 1;
			strcpy(wavefile,"stdout");
			break;

		case 0x101:    // --compile-debug
		case 0x102:		// --compile
			strncpy0(voicename,optarg,sizeof(voicename));
			flag_compile = c;
			quiet = 1;
			break;

		case 0x103:		// --punct
			option_punctuation = 1;
			if(optarg != NULL)
			{
				ix = 0;
				while((ix < N_PUNCTLIST) && ((option_punctlist[ix] = optarg[ix]) != 0)) ix++;
				option_punctlist[N_PUNCTLIST-1] = 0;
				option_punctuation = 2;
			}
			break;

		case 0x104:   // --voices
			espeak_Initialize(AUDIO_OUTPUT_SYNCHRONOUS,0,data_path,0);
			DisplayVoices(stdout,optarg);
			exit(0);

		case 0x106:   // -- split
			if(optarg == NULL)
				samples_split = 30;  // default 30 minutes
			else
				samples_split = atoi(optarg);
			break;

		case 0x107:  // --path
			data_path = optarg;
			break;

		case 0x108:  // --phonout
			if((f_phonemes_out = fopen(optarg,"w")) == NULL)
			{
				fprintf(stderr,"Can't write to: %s\n",optarg);
			}
			break;

		default:
			exit(0);
		}
	}


	if(option_waveout || quiet)
	{
		// writing to a file (or no output), we can use synchronous mode
		samplerate = espeak_Initialize(AUDIO_OUTPUT_SYNCHRONOUS,0,data_path,0);
		samples_split = (samplerate * samples_split) * 60;

		espeak_SetSynthCallback(SynthCallback);
		if(samples_split)
		{
			char *extn;
			extn = strrchr(wavefile,'.');
			if((extn != NULL) && ((wavefile + strlen(wavefile) - extn) <= 4))
			{
				strcpy(filetype,extn);
				*extn = 0;
			}
		}
		else
		if(option_waveout)
		{
			if(OpenWavFile(wavefile,samplerate) != 0)
				exit(4);
		}
	}
	else
	{
		// play the sound output
		samplerate = espeak_Initialize(AUDIO_OUTPUT_PLAYBACK,0,data_path,0);
	}
	

	if(voicename[0] == 0)
		strcpy(voicename,"default");

	if(espeak_SetVoiceByName(voicename) != EE_OK)
	{
		memset(&voice_select,0,sizeof(voice_select));
		voice_select.languages = voicename;
		if(espeak_SetVoiceByProperties(&voice_select) != EE_OK)
		{
			fprintf(stderr,"%svoice '%s'\n",err_load,voicename);
			exit(2);
		}
	}

	if(flag_compile)
	{
		// This must be done after the voice is set
		espeak_CompileDictionary("", stderr, flag_compile & 0x1);
		exit(0);
	}

	// set any non-default values of parameters. This must be done after espeak_Initialize()
	if(speed > 0)
		espeak_SetParameter(espeakRATE,speed,0);
	if(volume >= 0)
		espeak_SetParameter(espeakVOLUME,volume,0);
	if(pitch >= 0)
		espeak_SetParameter(espeakPITCH,pitch,0);
	if(option_capitals >= 0)
		espeak_SetParameter(espeakCAPITALS,option_capitals,0);
	if(option_punctuation >= 0)
		espeak_SetParameter(espeakPUNCTUATION,option_punctuation,0);
	if(wordgap >= 0)
		espeak_SetParameter(espeakWORDGAP,wordgap,0);
	if(option_linelength > 0)
		espeak_SetParameter(espeakLINELENGTH,option_linelength,0);
	if(option_punctuation == 2)
		espeak_SetPunctuationList(option_punctlist);
	espeak_SetPhonemeTrace(option_phonemes,f_phonemes_out);

	if(filename[0]==0)
	{
		if((optind < argc) && (flag_stdin == 0))
		{
			// there's a non-option parameter, and no -f or --stdin
			// use it as text
			p_text = argv[optind];
		}
		else
		{
			f_text = stdin;
			if(flag_stdin == 0)
			{
				flag_stdin = 2;
			}
		}
	}
	else
	{
		filesize = GetFileLength(filename);
		f_text = fopen(filename,"r");
	}

	if((f_text == NULL) && (p_text == NULL))
	{
		fprintf(stderr,"%sfile '%s'\n",err_load,filename);
		exit(1);
	}


	if(p_text != NULL)
	{
		int size;
		size = strlen(p_text);
		espeak_Synth(p_text,size+1,0,POS_CHARACTER,0,synth_flags,NULL,NULL);
	}
	else
	if(flag_stdin)
	{
		int max = 1000;
		p_text = (char *)malloc(max);

		if(flag_stdin == 2)
		{
			// line by line input on stdin
			while(fgets(p_text,max,stdin) != NULL)
			{
				p_text[max-1] = 0;
				espeak_Synth(p_text,max,0,POS_CHARACTER,0,synth_flags,NULL,NULL);

			}
		}
		else
		{
			// bulk input on stdin
			ix = 0;
			while(!feof(stdin))
			{
				p_text[ix++] = fgetc(stdin);
				if(ix >= (max-1))
				{
					max += 1000;
					p_text = (char *)realloc(p_text,max);
				}
			}
			if(ix > 0)
			{
				p_text[ix-1] = 0;
				espeak_Synth(p_text,ix+1,0,POS_CHARACTER,0,synth_flags,NULL,NULL);
			}
		}
	}
	else
	if(f_text != NULL)
	{
		if((p_text = (char *)malloc(filesize+1)) == NULL)
		{
			fprintf(stderr,"Failed to allocate memory %d bytes",filesize);
			exit(3);
		}

		fread(p_text,1,filesize,f_text);
		p_text[filesize]=0;
		espeak_Synth(p_text,filesize+1,0,POS_CHARACTER,0,synth_flags,NULL,NULL);
		fclose(f_text);
	}

	espeak_Synchronize();
	return(0);
}
