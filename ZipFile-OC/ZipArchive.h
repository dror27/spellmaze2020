//
//  ZipArchive.h
//  
//
//  Created by aish on 08-9-11.
//  acsolu@gmail.com
//  Copyright 2008  Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "zip.h"
#include "unzip.h"

@class ZipArchive;
@protocol ZipArchiveDelegate <NSObject>
@optional
-(void)zipArchive:(ZipArchive*)zipArchive errorMessage:(NSString*) msg;
-(BOOL)zipArchive:(ZipArchive*)zipArchive overWriteOperation:(NSString*) file;
-(void)zipArchive:(ZipArchive*)zipArchive processingFile:(NSString*) file;

@end


@interface ZipArchive : NSObject {
@private
	zipFile		_zipFile;
	unzFile		_unzFile;
	
	id			_delegate;
	
	BOOL		_cleanFolders;
}

@property (nonatomic, retain) id delegate;
@property BOOL cleanFolders;

-(BOOL) CreateZipFile2:(NSString*) zipFile;
-(BOOL) addFileToZip:(NSString*) file newname:(NSString*) newname;
-(BOOL) CloseZipFile2;

-(BOOL) UnzipOpenFile:(NSString*) zipFile;
-(int)  UnzipCountFiles;
-(BOOL) UnzipFileTo:(NSString*) path overWrite:(BOOL) overwrite;
-(BOOL) UnzipCloseFile;
@end
