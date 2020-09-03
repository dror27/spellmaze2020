#if SCRIPTING
//
//  ByLanguageUUIDGameLevelFactory.h
//  Board3
//
//  Created by Dror Kessler on 9/11/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ByUUIDGameLevelFactory.h"
#import "Language.h"

@interface ByLanguageUUIDGameLevelFactory : ByUUIDGameLevelFactory {

	id<Language>	_language;
}
@property (retain) id<Language> language;

-(id)initWithUUID:(NSString*)uuid;

@end
#endif
