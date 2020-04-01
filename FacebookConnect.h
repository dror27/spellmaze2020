//
//  FacebookConnect.h
//  Board3
//
//  Created by Dror Kessler on 9/1/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect/FBConnect.h"
#import "PrefThreadedActionItem.h"

@interface FacebookConnect : NSObject<FBSessionDelegate,FBRequestDelegate,FBDialogDelegate> {

	FBSession*			_fbSession;
	FBUID				_uid;
	
	BOOL				_loggedIn;
	BOOL				_loginDialogCanceled;
	BOOL				_requestDone;
	BOOL				_requestFailed;
	
	NSString*				_languageUUID;
	PrefThreadedActionItem*	_item;
	
	NSArray*			_requestResult;
}
@property (retain) FBSession* fbSession;
@property BOOL loggedIn;
@property FBUID uid; 
@property (retain) NSString* languageUUID;
@property (retain) PrefThreadedActionItem* item;
@property (retain) NSArray* requestResult;

+(FacebookConnect*)singleton;
-(BOOL)login;
-(BOOL)updateFriendsOntology:(NSString*)uuid withActionItem:(PrefThreadedActionItem*)item;

@end
