/*
 *  GameBoardLogic.h
 *  Board3
 *
 *  Created by Dror Kessler on 5/22/09.
 *  Copyright 2020 Dror Kessler (M). All rights reserved.
 *
 */

#import "Piece.h"
#import "Board.h"
#import "WordValidator.h"

@protocol GameBoardLogic <NSObject>

-(BOOL)willAcceptPiece;
-(void)pieceDispensed:(id<Piece>)piece;
-(void)pieceSelected:(id<Piece>)piece;
-(void)pieceReselected:(id<Piece>)piece;
-(void)validWordSelected:(NSString*)word;
-(void)invalidWordSelected:(NSString*)word;
-(void)wordSelectionCanceled;
-(void)onGameTimer;
-(void)onFineGameTimer;
-(void)onGameWon;
-(void)onGameOver;
-(int)scoreSuggested:(int)score forPieces:(NSArray*)pieces;
-(NSArray*)eliminationSuggested:(NSArray*)pieces;

-(NSString*)role;

-(CSetWrapper*)generateBoardWordSet:(NSMutableArray**)piecesOutput 
							forBoard:(id<Board>)board 
							withWordValidator:(id<WordValidator>)wordValidator 
							withMinWordSize:(int)minWordSize andMaxWordSize:(int)maxWordSize 
							andBlackList:(CSetWrapper*)blackList;
-(NSString*)generateBoardWordSetRole;

-(BOOL)includesRole:(NSString*)role;
-(id<GameBoardLogic>)getIncludedRole:(NSString*)role;


@end

