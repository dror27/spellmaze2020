#if SCRIPTING
//
//  JIMInterp.h
//  Board3
//
//  Created by Dror Kessler on 5/22/09.
//  Copyright 2009 Dror Kessler (M). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jim.h"

@interface JIMInterp : NSObject {

	Jim_Interp*		m_interp;
}
+(JIMInterp*)interp;

-(id)eval:(NSString*)expr;
-(int)evalInt:(NSString*)expr;
-(float)evalFloat:(NSString*)expr;
-(double)evalDouble:(NSString*)expr;
-(id)eval:(NSString*)expr withPath:(NSString*)path;

-(NSString*)result;

-(void)addClassCommand:(NSString*)clazz;

+(NSString*)objectAsCommand:(id)obj;
-(void)setInterpResult:(id)value withType:(char)type;
-(id)getTypedJimObj:(Jim_Obj*)jimObj withType:(char)type;
-(double)getDoubleTypedJimObj:(Jim_Obj*)jimObj;
@end
#endif
