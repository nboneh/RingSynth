//
//  Layout.h
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Staff.h"
#import "Measure.h"
#import "ObjectAL.h"

@interface Layout  : UIView<MeasureDelegate>{
    NSMutableArray *measures;
    int prevMeasure;
    NSTimer *playTimer;
    int bpm;
    ALChannelSource *channel;
    Staff *staff;
}
@property (readonly)int currentMeasurePlaying;
@property (readonly)int widthFromFirstMeasure;
@property(readonly) int widthPerMeasure;
@property (nonatomic)int numOfMeasures;
-(id) initWithStaff:(Staff *)staff andFrame:(CGRect)frame andNumOfMeasure:(int)numOfMeasures;
-(void)playWithTempo:(int)bpm fromMeasure:(int)measure;
-(void)stop;
-(Measure *)findMeasureAtx:(int)x;
-(void)setMuted:(BOOL)abool;
-(NSArray*)createSaveFile;
-(void)loadSaveFile:(NSArray *)saveFile;
@end
