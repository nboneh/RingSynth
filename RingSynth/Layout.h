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

@interface Layout  : UIView{
    int prevBeat;
    NSTimer *playTimer;
    int bpm;
    Staff *staff;
}
@property(readonly)ALChannelSource*channel;
@property (readonly)NSMutableArray *beats;
@property (readonly)int currentBeatPlaying;
@property (readonly)int widthFromFirstBeat;
@property(readonly) int widthPerBeat;
@property (nonatomic)int numOfBeats;
-(id) initWithStaff:(Staff *)staff andFrame:(CGRect)frame andNumOfBeat:(int)numOfBeats;
-(void)playWithTempo:(int)bpm fromBeat:(int)beat;
-(void)stop;
-(Beat *)findBeatAtx:(int)x;
-(void)setMuted:(BOOL)abool;
-(NSArray*)createSaveFile;
-(void)loadSaveFile:(NSArray *)saveFile;
@end
