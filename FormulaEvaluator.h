//
//  FormulaEvaluator.h
//  SpellMaze
//
//  Created by Dror Kessler on 10/16/09.
//  Copyright 2020 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FormulaEvaluator : NSObject {
	
}
+(FormulaEvaluator*)evaluator;

-(id)eval:(NSString*)formula;
-(NSString*)evalToString:(NSString*)formula;

@end
