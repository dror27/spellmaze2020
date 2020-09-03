#if SCRIPTING
//
//  JimTestClass.h
//  Board3
//
//  Created by Dror Kessler on 5/29/09.
//  Copyright 2020 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JimTestClass : NSObject {

}

+(id)classMethod_Returns_Id;
+(NSString*)classMethod_Returns_NSString;
+(int)classMethod_Returns_Int;
+(float)classMethod_Returns_Float;

-(id)instanceMethod_Returns_Id;
-(NSString*)instanceMethod_Returns_NSString;
-(int)instanceMethod_Returns_Int;
-(float)instanceMethod_Returns_Float;

-(int)instanceMethod_Returns_Int_Add:(int)a with:(int)b;
@end
#endif
