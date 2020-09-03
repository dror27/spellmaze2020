#if SCRIPTING
//
//  JIMHelper.h
//  Board3
//
//  Created by Dror Kessler on 5/22/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jim.h"

@interface JIMHelper : NSObject {

}
+(NSString*)string:(Jim_Obj*)obj;
@end
#endif
