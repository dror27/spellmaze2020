//
//  Folders.h
//  Board3
//
//  Created by Dror Kessler on 8/5/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>

#define		DF_LANGUAGES			@"Ontologies"
#define		DF_LEVELS				@"Levels"
#define		DF_GAMES				@"Games"
#define		DF_BRANDS				@"Brands"

#define		DF_CATALOGS				@"Catalogs"

#define		DF_DYNAMIC				@"Dynamic"

typedef enum 
{
	FolderRoleEOL = 0,
	FolderRoleBuiltin,
	FolderRoleDownload,
	FolderRoleCurrentGame
} FolderRoleType;

@interface Folders : NSObject {

}

+(NSArray*)defaultRoleSearchOrder;

+(NSString*)roleFolder:(FolderRoleType)role forDomain:(NSString*)domain;
+(NSString*)temporaryFolder;

+(NSArray*)listUUIDSubFolders:(NSArray*)roleSearchOrder forDomain:(NSString*)domain;
+(NSString*)findUUIDSubFolder:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid;
+(NSString*)findMutableUUIDSubFolder:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid;

+(NSString*)makeUUIDMutable:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid;


+(NSMutableDictionary*)getMutableFolderProps:(NSString*)folder withPropsFilename:(NSString*)filename returnDefaultIfNotPresent:(BOOL)returnDefaultIfNotPresent;
+(NSMutableDictionary*)getMutableFolderProps:(NSString*)folder;
+(void)setProps:(NSDictionary*)props forFolder:(NSString*)folder;

+(NSMutableDictionary*)findUUIDProps:(NSArray*)roleSearchOrder forDomain:(NSString*)domain withUUID:(NSString*)uuid;
+(void)setProps:(NSDictionary*)props forUUID:(NSString*)uuid forDomain:(NSString*)domain withRoleSearchOrder:(NSArray*)roleSearchOrder;

+(NSArray*)listDomain:(NSString*)domain withRoleSearchOrder:(NSArray*)roleSearchOrder;
+(NSArray*)listDomainSorted:(NSString*)domain withRoleSearchOrder:(NSArray*)roleSearchOrder;
+(void)clearDomainCache:(NSString*)domain;

+(void)clearRoleFolder:(FolderRoleType)role forDomain:(NSString*)domain;

+(void)copyFolder:(NSString*)srcFolder toFolder:(NSString*)dstFolder;
+(void)removeFolder:(NSString*)folder;

+(void)reportUUIDUpdated:(NSString*)uuid withDomain:(NSString*)domain;


@end
