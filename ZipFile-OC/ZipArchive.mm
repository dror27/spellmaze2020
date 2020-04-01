//
//  ZipArchive.mm
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import "ZipArchive.h"
#import "zlib.h"
#import "zconf.h"

#define	UTF8_FILENAMES

@interface ZipArchive (Private)

-(void) OutputErrorMessage:(NSString*) msg;
-(BOOL) OverWrite:(NSString*) file;
-(void) ReportProcessingFile:(NSString*) file;
@end



@implementation ZipArchive
@synthesize delegate = _delegate;
@synthesize cleanFolders = _cleanFolders;

-(id) init
{
	if( self=[super init] )
	{
		_zipFile = NULL ;
	}
	return self;
}

-(void) dealloc
{
	[self CloseZipFile2];
	[super dealloc];
}

-(BOOL) CreateZipFile2:(NSString*) zipFile
{
	_zipFile = zipOpen( (const char*)[zipFile UTF8String], 0 );
	if( !_zipFile ) 
		return NO;
	return YES;
}
-(BOOL) addFileToZip:(NSString*) file newname:(NSString*) newname;
{
	if( !_zipFile )
		return NO;
//	tm_zip filetime;
	time_t current;
	time( &current );
	
	zip_fileinfo zipInfo = {0};
	zipInfo.dosDate = (unsigned long) current;
	
	
	int ret = zipOpenNewFileInZip( _zipFile,
								  (const char*) [newname UTF8String],
								  &zipInfo,
								  NULL,0,
								  NULL,0,
								  NULL,//comment
								  Z_DEFLATED,
								  Z_DEFAULT_COMPRESSION );
	if( ret!=Z_OK )
	{
		return NO;
	}
	NSData* data = [ NSData dataWithContentsOfFile:file];
	unsigned int dataLen = [data length];
	ret = zipWriteInFileInZip( _zipFile, (const void*)[data bytes], dataLen);
	if( ret!=Z_OK )
	{
		return NO;
	}
	ret = zipCloseFileInZip( _zipFile );
	if( ret!=Z_OK )
		return NO;
	return YES;
}
-(BOOL) CloseZipFile2
{
	if( _zipFile==NULL )
		return NO;
	BOOL ret =  zipClose( _zipFile,NULL )==Z_OK?YES:NO;
	_zipFile = NULL;
	return ret;
}

-(BOOL) UnzipOpenFile:(NSString*) zipFile
{
	_unzFile = unzOpen( (const char*)[zipFile UTF8String] );
	if( _unzFile )
	{
		unz_global_info  globalInfo = {0};
		if( unzGetGlobalInfo(_unzFile, &globalInfo )==UNZ_OK )
		{
			NSLog([NSString stringWithFormat:@"%d entries in the zip file",globalInfo.number_entry] );
		}
	}
	return _unzFile!=NULL;
}
-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite
{
	BOOL success = YES;
	int ret = unzGoToFirstFile( _unzFile );
	unsigned char		buffer[4096] = {0};
	NSFileManager* fman = [NSFileManager defaultManager];
	if( ret!=UNZ_OK )
	{
		[self OutputErrorMessage:@"Failed"];
	}
	
	do{
		ret = unzOpenCurrentFile( _unzFile );
		if( ret!=UNZ_OK )
		{
			[self OutputErrorMessage:@"Error occurs"];
			success = NO;
			break;
		}
		// reading data and write to file
		int read ;
		unz_file_info	fileInfo ={0};
		ret = unzGetCurrentFileInfo(_unzFile, &fileInfo, NULL, 0, NULL, 0, NULL, 0);
		if( ret!=UNZ_OK )
		{
			[self OutputErrorMessage:@"Error occurs while getting file info"];
			success = NO;
			unzCloseCurrentFile( _unzFile );
			break;
		}
		char* filename = (char*) malloc( fileInfo.size_filename +1 );
		unzGetCurrentFileInfo(_unzFile, &fileInfo, filename, fileInfo.size_filename + 1, NULL, 0, NULL, 0);
		filename[fileInfo.size_filename] = '\0';
		
		// check if it contains directory
#ifdef UTF8_FILENAMES
		NSString * strPath = [NSString  stringWithUTF8String:filename];
#else
		NSString * strPath = [NSString  stringWithCString:filename];
#endif
		BOOL isDirectory = NO;
		if( filename[fileInfo.size_filename-1]=='/' || filename[fileInfo.size_filename-1]=='\\')
			isDirectory = YES;
		free( filename );
		if( [strPath rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/\\"]].location!=NSNotFound )
		{// contains a path
			strPath = [strPath stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
		}
		NSString* fullPath = [path stringByAppendingPathComponent:strPath];
		
		[self ReportProcessingFile:fullPath];
		
		if( isDirectory )
		{
			// always start with clean directories?
			if ( self.cleanFolders )
				[fman removeItemAtPath:fullPath error:nil];
			
			[fman createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		else
			[fman createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
		if( [fman fileExistsAtPath:fullPath] && !isDirectory && !overwrite )
		{
			if( ![self OverWrite:fullPath] )
			{
				unzCloseCurrentFile( _unzFile );
				ret = unzGoToNextFile( _unzFile );
				continue;
			}
		}
		FILE* fp = fopen( (const char*)[fullPath UTF8String], "wb");
		while( fp )
		{
			read=unzReadCurrentFile(_unzFile, buffer, 4096);
			if( read > 0 )
			{
				fwrite(buffer, read, 1, fp );
			}
			else if( read<0 )
			{
				[self OutputErrorMessage:@"Failed to reading zip file"];
				break;
			}
			else 
				break;				
		}
		if( fp )
			fclose( fp );
		unzCloseCurrentFile( _unzFile );
		ret = unzGoToNextFile( _unzFile );
	}while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );
	return success;
}

-(int) UnzipCountFiles
{
	BOOL success = YES;
	int ret = unzGoToFirstFile( _unzFile );
	int					count = 0;
	if( ret!=UNZ_OK )
	{
		[self OutputErrorMessage:@"Failed"];
	}
	
	do{
		count++;
		ret = unzOpenCurrentFile( _unzFile );
		if( ret!=UNZ_OK )
		{
			[self OutputErrorMessage:@"Error occurs"];
			success = NO;
			break;
		}
		unzCloseCurrentFile( _unzFile );
		ret = unzGoToNextFile( _unzFile );
	}while( ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE );

	
	return success ? count : 0;
}



-(BOOL) UnzipCloseFile
{
	if( _unzFile )
		return unzClose( _unzFile )==UNZ_OK;
	return YES;
}

#pragma mark wrapper for delegate
-(void) OutputErrorMessage:(NSString*) msg
{
	if( _delegate && [_delegate respondsToSelector:@selector(zipArchive:errorMessage:)] )
		[_delegate zipArchive:self errorMessage:msg];
}

-(BOOL) OverWrite:(NSString*) file
{
	if( _delegate && [_delegate respondsToSelector:@selector(zipArchive:overWriteOperation:)] )
		return [_delegate zipArchive:self overWriteOperation:file];
	return YES;
}

-(void) ReportProcessingFile:(NSString*) file
{
	if( _delegate && [_delegate respondsToSelector:@selector(zipArchive:processingFile:)] )
		[_delegate zipArchive:self processingFile:file];
}



@end
