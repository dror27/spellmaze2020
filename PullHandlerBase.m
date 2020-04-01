//
//  PullHandlerBase.m
//  Board3
//
//  Created by Dror Kessler on 9/25/09.
//  Copyright 2009 Dror Kessler. All rights reserved.
//

#import "PullHandlerBase.h"
#import "ScoresComm.h"

//#define	DUMP


@implementation PullHandlerBase
@synthesize pullRequest = _pullRequest;

-(id)initWithPullRequest:(NSDictionary*)pullRequest
{
	if ( self = [super init] )
	{
		self.pullRequest = pullRequest;
	}
	return self;
}

-(void)dealloc
{
	[_pullRequest release];
	
	[super dealloc];
}	

-(NSArray*)doPush:(NSData*)requestData withUrlSuffix:(NSString*)urlSuffix;
{
	// establish url
	NSURL*			baseUrl = [NSURL URLWithString:[NSString stringWithFormat:NSEP_URL, NSEP_VERSION]];
	NSString*		urlString = [_pullRequest objectForKey:@"url"];
	if ( urlSuffix )
	{
		if ( [urlString rangeOfString:@"?"].length > 0 )
			urlString = [urlString stringByAppendingFormat:@"&%@", urlSuffix];
		else
			urlString = [urlString stringByAppendingFormat:@"?%@", urlSuffix];
	}
	NSURL*			url = [NSURL URLWithString:urlString relativeToURL:baseUrl];
#ifdef	DUMP
	NSLog(@"[PullHandlerBase] sending %@ (%d bytes)", url, [requestData length]);
	NSLog(@"[PullHandlerBase] request: \n%@", [[[NSString alloc] initWithBytes:[requestData bytes] length:[requestData length] encoding:NSUTF8StringEncoding] autorelease]);
#endif
	
	// send file's content, get next pull request
	NSMutableURLRequest*	request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:requestData];
	
	// send and get response
	NSURLResponse*			response;
	NSError*				error;
	NSPropertyListFormat	format;
	NSString*				errorString;
	NSData*					responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	if ( !responseData || error )
	{
		NSLog(@"ERROR - %@", error);
		return NULL;		
	}
#ifdef	DUMP
	NSLog(@"[PullHandlerBase] response: \n%@", [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding] autorelease]);
#endif
	NSMutableDictionary*	responseProps = [NSPropertyListSerialization propertyListFromData:responseData 
																		  mutabilityOption:NSPropertyListMutableContainersAndLeaves 
																					format:&format
																		  errorDescription:&errorString];
	if ( !responseProps || errorString )
	{
		NSLog(@"ERROR - %@", errorString);
		if ( responseData )
		{
			NSString*	responseText = [[[NSString alloc] initWithBytes:[responseData bytes] length:[responseData length] encoding:NSUTF8StringEncoding] autorelease];
			NSLog(@"responseData:\n%@", responseText);
		}
		return NULL;		
	}
	
	// print error?
	if ( [responseProps objectForKey:@"error"] )
	{
		NSLog(@"SEP SERVER ERROR: %@", [responseProps objectForKey:@"error"]);
		return NULL;
	}
	else
		return [responseProps objectForKey:@"pull-requests"];
}

@end
