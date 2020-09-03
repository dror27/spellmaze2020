#if SCRIPTING
//
//  JimTestClass.m
//  Board3
//
//  Created by Dror Kessler on 5/29/09.
//  Copyright 2020 Dror Kessler (M-1). All rights reserved.
//

#import "JimTestClass.h"


@implementation JimTestClass

+(id)classMethod_Returns_Id { return [JimTestClass alloc]; }
+(NSString*)classMethod_Returns_NSString { return @"test"; }
+(int)classMethod_Returns_Int { return 18; }
+(float)classMethod_Returns_Float { return 12.34; }

-(id)instanceMethod_Returns_Id { return self; }
-(NSString*)instanceMethod_Returns_NSString { return @"test1"; }
-(int)instanceMethod_Returns_Int { return 19; }
-(float)instanceMethod_Returns_Float { return 56.78; }

-(int)instanceMethod_Returns_Int_Add:(int)a with:(int)b { return a + b; }
@end
#endif
