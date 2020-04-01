//
//  ReportLogPullHandler.m
//  Board3
//
//  Created by Dror Kessler on 9/24/09.
//  Copyright 2009 Dror Kessler. All rights reserved.
//

#import "ReportLogPullHandler.h"
#import "ScoresDatabase.h"
#import "ScoresComm.h"

//#define DUMP

@implementation ReportLogPullHandler

-(NSArray*)push
{
	// delete report logs?
	NSArray*		deleteReportLogs = [_pullRequest objectForKey:@"delete-report-logs"];
	if ( deleteReportLogs && [deleteReportLogs isKindOfClass:[NSArray class]] )
		for ( NSString* reportLog in deleteReportLogs )
		{
			NSError*		error = NULL;
			NSString*		path = [[ScoresDatabase singleton] pathForReportLog:reportLog];
#ifdef DUMP
			NSLog(@"[ReportLogPullHnadler] - deleting %@", path);
#endif
			[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
			if ( error )
			{
				NSLog(@"ERROR - %@", error);
			}
		}
	
	// get oldest report log still present on disk
	NSString*		reportLog = [[ScoresDatabase singleton] oldestReportLog];
	if ( !reportLog )
		return NULL;
	
	// establish path to report log file
	NSString*		path = [[ScoresDatabase singleton] pathForReportLog:(NSString*)reportLog];
		
	// let base do the hard (sending/recieving) work ...
	return [self doPush:[NSData dataWithContentsOfFile:path] withUrlSuffix:[NSString stringWithFormat:@"report-log=%@", reportLog]];
}

@end
