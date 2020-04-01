//
//  FacebookConnect.m
//  Board3
//
//  Created by Dror Kessler on 9/1/09.
//  Copyright 2009 Dror Kessler (M-1). All rights reserved.
//

#import "FacebookConnect.h"
#import "Folders.h"
#import "ScoresDatabase.h"

extern time_t appStartedAt;

#define PIC_FIELD_NORMAL			@"pic_big"
#define PIC_FIELD_MANY_FRIENDS		@"pic"
#define	MANY_FRIENDS_THRESHOLD		100

extern NSMutableDictionary*	globalData;
#define SINGLETON_KEY		@"FacebookConnect_singleton"

@implementation FacebookConnect
@synthesize fbSession = _fbSession;
@synthesize loggedIn = _loggedIn;
@synthesize uid = _uid;
@synthesize languageUUID = _languageUUID;
@synthesize item = _item;
@synthesize requestResult = _requestResult;

+(FacebookConnect*)singleton
{
	@synchronized ([FacebookConnect class])
	{
		if ( ![globalData objectForKey:SINGLETON_KEY] )
		{
			[globalData setObject:[[[FacebookConnect alloc] init] autorelease] forKey:SINGLETON_KEY];
		}
	}
	return [globalData objectForKey:SINGLETON_KEY];
}

-(id)init
{
	if ( self = [super init] )
	{
		self.fbSession = [FBSession sessionForApplication:@"2b955f5b56b1bc9fc9aa94fe1e483eaa" 
													secret:@"e00365992b6ccc4dae7b48b1a6fb6f93" delegate:self];
	}
	return self;
}

-(void)dealloc
{
	[_fbSession release];
	[_languageUUID release];
	[_item release];
	[_requestResult release];
	
	[super dealloc];
}

-(BOOL)login
{
#ifdef DUMP
	NSLog(@"login");
#endif
	
	if ( !self.loggedIn )
	{
		_loginDialogCanceled = FALSE;
		[self performSelectorOnMainThread:@selector(showLoginDialog:) withObject:self waitUntilDone:TRUE];
		while ( !self.loggedIn && !_loginDialogCanceled )
			sleep(1);
	}
	if ( !self.loggedIn )
		return(FALSE);
#ifdef DUMP
	NSLog(@"login: loggedIn");
#endif
	
	return(TRUE);
}

-(BOOL)updateFriendsOntology:(NSString*)uuid withActionItem:(PrefThreadedActionItem*)item;
{	
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_FACEBOOK_START withTimeDelta:time(NULL) - appStartedAt];

#ifdef DUMP
	NSLog(@"updateFriendsOntology: %@", uuid);
#endif
	self.languageUUID = uuid;
	self.item = item;
	[self.item updateProgress:-1.0 withMessage:LOC(@"Getting Friends ...")];
		
	// get lists and counts
	_requestDone = _requestFailed = FALSE;
	[self performSelectorOnMainThread:@selector(sendListsQuery:) withObject:self waitUntilDone:TRUE];
	while ( !_requestDone )
		sleep(1);
	if ( _requestFailed )
	{
		[self.item updateProgress:-1.0 withMessage:LOC(@"Request Failed 1")];
		[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_FACEBOOK_FAILED withTimeDelta:time(NULL) - appStartedAt];
		return TRUE;
	}
	NSArray*		lists = self.requestResult;
#ifdef DUMP
	NSLog(@"sendListsQuery result: %@", lists);
#endif
	NSString*		spellMazeList = nil;
	for ( NSDictionary* list in lists )
		if ( [[list objectForKey:@"name"] isEqualToString:@"SpellMaze"] )
		{
			spellMazeList = [list objectForKey:@"flid"];
#ifdef DUMP			
			NSLog(@"found SpellMaze group: %@", spellMazeList);
#endif
			[self.item updateProgress:-1.0 withMessage:[NSString stringWithFormat:LOC(@"%@ List ..."),[list objectForKey:@"name"] ]];
			break;
		}
	
	// get fields
	_requestDone = FALSE;
	[self performSelectorOnMainThread:@selector(sendFriendsQuery:) withObject:spellMazeList waitUntilDone:TRUE];
	while ( !_requestDone )
		sleep(1);
	if ( _requestFailed )
	{
		[self.item updateProgress:-1.0 withMessage:LOC(@"Request Failed 2")];
		[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_FACEBOOK_FAILED withTimeDelta:time(NULL) - appStartedAt];
		return TRUE;
	}
	
	// get names and picture urls
	NSArray*		users = self.requestResult;
	[self.item updateProgress:-1.0 withMessage:[NSString stringWithFormat:LOC(@"%d Friends ..."), [users count]]];
	sleep(1);
	
	// determine which picture field to use
	NSString*		picField = ([users count] <= MANY_FRIENDS_THRESHOLD) ? PIC_FIELD_NORMAL : PIC_FIELD_MANY_FRIENDS;
	
	NSMutableArray*	names = [[[NSMutableArray alloc] init] autorelease];
	NSMutableDictionary* images = [[[NSMutableDictionary alloc] init] autorelease];
	for ( NSDictionary* user in users )
	{
#ifdef DUMP
		for ( NSString* key in [user allKeys] )
			NSLog(@"%@ = %@", key, [user objectForKey:key]);
#endif
		
		NSString*	name = [user objectForKey:@"name"];
		
		/* skip this name? 
		if ( [name hasPrefix:@"א"] )
			continue;
		*/
		
		NSString*	pic = [user objectForKey:picField];
		name = [name uppercaseString];
		
		[names addObject:name];
		if ( pic && ![pic isKindOfClass:[NSNull class]] )
			[images setObject:[NSURL URLWithString:pic] forKey:name];
	}
	
	// write names as the language's words
	NSMutableString*	words = [NSMutableString stringWithString:@""];
	[words appendFormat:@"# FacebookConnect\n\n"];
	for ( NSString* name in names )
		[words appendFormat:@"%@\n", name];
	NSString*			folder = [Folders findUUIDSubFolder:NULL forDomain:DF_LANGUAGES withUUID:self.languageUUID];
	NSString*			path = [folder stringByAppendingPathComponent:@"words.txt"];
	NSError*			error;
	if ( ![words writeToFile:path atomically:FALSE encoding:NSUTF8StringEncoding error:&error] )
		NSLog(@"ERROR - %@", error);
	
	// save pictures
	NSString*			imagesPath = [folder stringByAppendingPathComponent:@"images"];
	[[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:TRUE attributes:NULL error:nil];
	int					picIndex = 0;
	int					picCount = [[images allKeys] count];
	for ( NSString* name in [images allKeys] )
	{
		NSAutoreleasePool*	pool = [[NSAutoreleasePool alloc] init];
		
		[self.item updateProgress:(float)picIndex++ / picCount withMessage:@"Getting Pictures"];
		
		NSURL*		url = [images objectForKey:name];
		
		NSData*		data = [NSData dataWithContentsOfURL:url];
		if ( data )
		{
			UIImage*	image = [UIImage imageWithData:data];
			NSData*		imageData = UIImageJPEGRepresentation(image, 0.8);
			NSString*	filename = [imagesPath stringByAppendingPathComponent:[name stringByAppendingString:@".jpg"]];
			
#ifdef DUMP
			NSLog(@"filename: %@", filename);
#endif
			
			if ( ![imageData writeToFile:filename atomically:FALSE] )
				NSLog(@"writing of image data failed");
			else
			{
#ifdef DUMP
				NSLog(@"wrote image for %@", name);
#endif
			}
		}
		
		[pool release];
	}
	[[ScoresDatabase singleton] reportLevelEvent:NULL withType:RT_FACEBOOK_OK withTimeDelta:time(NULL) - appStartedAt];
	
	return(TRUE);
}

-(void)showLoginDialog:(id)sender
{
	FBLoginDialog* dialog = [[[FBLoginDialog alloc] initWithSession:self.fbSession] autorelease];
	dialog.delegate = self;
	[dialog show];	
}

-(void)sendFriendsQuery:(id)sender
{
	NSString*		flid = sender;
	NSString*		fql;
	
	if ( !flid )
	{
		// not reading from a list
		fql = [NSString stringWithFormat:@"select name,%@,%@ from user where uid in (select uid2 from friend where uid1==%llu)", PIC_FIELD_NORMAL, PIC_FIELD_MANY_FRIENDS, self.uid];
	}
	else
	{
		// reading from a list
		fql = [NSString stringWithFormat:@"select name,%@,%@ from user where uid in (select uid from friendlist_member where flid==%@)", PIC_FIELD_NORMAL, PIC_FIELD_MANY_FRIENDS, flid];
	}
#ifdef DUMP
	NSLog(@"fql: %@", fql);
#endif
	
	NSDictionary*	params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];	
}

-(void)sendListsQuery:(id)sender
{
	NSString*		fql = [NSString stringWithFormat:@"SELECT flid, name FROM friendlist WHERE owner=%llu", self.uid];
#ifdef DUMP
	NSLog(@"fql: %@", fql);
#endif
	
	NSDictionary*	params = [NSDictionary dictionaryWithObject:fql forKey:@"query"];
	
	[[FBRequest requestWithDelegate:self] call:@"facebook.fql.query" params:params];	
}



-(void)dialogDidCancel:(FBDialog*)dialog
{
#ifdef DUMP
	NSLog(@"dialogDidCancel");
#endif
	_loginDialogCanceled = TRUE;
}

-(void)dialog:(FBDialog*)dialog didFailWithError:(NSError*)error
{
	NSLog(@"dialog:didFailWithError: %@", error);
	
	_loginDialogCanceled = TRUE;	
}


-(void)session:(FBSession*)session didLogin:(FBUID)uid
{
#ifdef DUMP
	NSLog(@"fb: session=%llu", uid);
#endif

	if ( uid == (FBUID)-1 || uid == 2147483647 )
	{
		self.loggedIn = FALSE;
		_loginDialogCanceled = TRUE;
	}
	else
	{
		self.uid = uid;
		self.loggedIn = TRUE;
	}
}

-(void)request:(FBRequest*)request didLoad:(id)result
{
#ifdef DUMP
	NSLog(@"fb: request:didLoad: request=%p, result=%@", request, result);
#endif
	
	self.requestResult = result;
	
	_requestDone = TRUE;
}

-(void)requestWasCancelled:(FBRequest*)request
{
#ifdef DUMP
	NSLog(@"fb: requestWasCancelled: request=%p", request);
#endif
	_requestDone = TRUE;
}

-(void)request:(FBRequest*)request didFailWithError:(NSError*)error
{
	NSLog(@"fb: request:didFailWithError: request=%p, error=%@", request, error);
	_requestDone = TRUE;
}



@end
