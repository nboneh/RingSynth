//
//  Layout.h
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Staff.h"
#import "Beat.h"
#import "ObjectAL.h"

typedef enum {
    all_mode = 0,
    active =1,
    not_active =2
} LayerState;
@protocol LayoutDelegate
@optional
-(void)changeSubDivision:(Subdivision)subdivision forBeatNum:(int)num;
@end
@interface Layout  : UIView<BeatDelegate>{
    Staff *staff;
}
@property(readonly)ALChannelSource*channel;
@property (readonly)NSMutableArray *beats;
@property (readonly)int widthFromFirstBeat;
@property(readonly) int widthPerBeat;
@property (nonatomic)int numOfBeats;
@property(nonatomic,assign)id delegate;

-(id) initWithStaff:(Staff *)staff andFrame:(CGRect)frame andNumOfBeat:(int)numOfBeats;
-(void)playWithTempo:(int)bpm beat:(int)index tic:(int)tic andTicDivision:(int)ticDivision;
-(Beat *)findBeatAtx:(int)x;
-(int)findBeatIndexAtx:(int)x;
-(Beat *)findBeatAtIndex:(int)ind;
-(void)stopBeat;
-(void)setMuted:(BOOL)abool;
-(NSArray*)createSaveFile;
-(void)loadSaveFile:(NSArray *)saveFile;
-(void)remove;
-(void)setState:(LayerState)state;

-(void)clearBeat:(int)startBeat to:(int)endBeat;
-(void)duplicateBeat:(int)startBeat to:(int)endBeat insert:(int)insertBeat;
-(void)moveBeat:(int)startBeat to:(int)endBeat insert:(int)insertBeat;

@end
