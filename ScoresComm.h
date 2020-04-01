//
//  ScoresComm.h
//  Board3
//
//  Created by Dror Kessler on 9/23/09.
//  Copyright 2009 Dror Kessler. All rights reserved.
//

#import <Foundation/Foundation.h>

#define			NSEP_VERSION	@"0.3"
#if TARGET_IPHONE_SIMULATOR
#define		NSEP_URL		@"http://localhost/~drorkessler/sep/sep%@.php"
//#define		NSEP_URL		@"http://www.language-machines.com/sep/sep%@.php"
#else
#define		NSEP_URL		@"http://www.language-machines.com/sep/sep%@.php"
#endif

#define		SCORES_TYPE_GLOBAL		@"global"
#define		SCORES_TYPE_GAME		@"game_language"
#define		SCORES_TYPE_MY_GLOBAL	@"my_global"
#define		SCORES_TYPE_MY_GAME		@"my_game_language"

@interface ScoresComm : NSObject {

	NSString*		_type;
}
@property (retain) NSString* type;
-(void)advanceTypeToNext;
-(NSString*)getLocalizedTitleForType:(NSString*)type;
-(NSString*)getLocalizedSubTitleForType:(NSString*)type;
-(BOOL)isOnFirstType;

-(NSDictionary*)buildScoreRequest;
-(NSDictionary*)fetchScoreRespose;

@end
