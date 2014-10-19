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

@interface Layout  : UIView<MeasureDelegate>{
    NSArray *measures;
    int currentMeasurePlaying;
    NSTimer *playTimer;
    int bpm;
}
@property (readonly)int widthFromFirstMeasure;
@property(readonly) float widthPerMeasure;
-(id) initWithStaff:(Staff *)staff andFrame:(CGRect)frame andNumOfMeasure:(int)numOfMeasures;
-(void)playWithTempo:(int)bpm;
-(void)stop;
-(Measure *)findMeasureAtx:(int)x;
@end
