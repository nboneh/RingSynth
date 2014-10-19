//
//  Layout.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Layout.h"

@interface Layout()
//-(void)checkViews;
//-(NotesHolder *)findMeasureIfExistsAtX:(int)x;
@end
@implementation Layout

@synthesize widthPerMeasure = _widthPerMeasure;
-(id) initWithStaff:(Staff *)staff andFrame:(CGRect)frame andNumOfMeasure:(int)numOfMeasures{
    self = [super init];
    if(self){
        NSMutableArray *preMeasures = [[NSMutableArray alloc] init];
        int delX =staff.trebleView.frame.size.width;
         _widthPerMeasure = frame.size.width/4;
        for(int i = 0; i < numOfMeasures; i++){
            Measure* measure =[[Measure alloc] initWithStaff:staff andFrame:CGRectMake(delX, 0, _widthPerMeasure, frame.size.height) andNum:(i+1)];
            [preMeasures addObject:measure];
            delX += _widthPerMeasure;
            [self addSubview:measure];
            [measure setDelegate:self];
        
        }
        measures = [[NSArray alloc] initWithArray:preMeasures];

        self.frame = CGRectMake(0, 0,  _widthPerMeasure * numOfMeasures + staff.trebleView.frame.size.width,frame.size.height);
    }
    return self;
}

-(void)playWithTempo:(int)bpm_{
    currentMeasurePlaying = 0;
    bpm = bpm_;
    playTimer =[NSTimer scheduledTimerWithTimeInterval:(60.0f/bpm)
                                     target:self
                                   selector:@selector(playMeasure:)
                                   userInfo:nil
                                    repeats:YES];
    
}
-(void)playMeasure:(NSTimer *)target{
    if(currentMeasurePlaying < [measures count]){
        Measure * measure = [measures objectAtIndex:currentMeasurePlaying];
        [measure playWithTempo:bpm];
    } else{
        [self stop];
    }
    currentMeasurePlaying++;
}

-(void)stop{
    [playTimer invalidate];
    if(currentMeasurePlaying < [measures count]){
        Measure * measure = [measures objectAtIndex:currentMeasurePlaying];
        [measure stop];
    }
    playTimer = nil;
}
-(void)changeSubDivision:(Subdivision)subdivision{
    NSInteger size = [measures count];
    for(int i = 0; i < size; i++){
        Measure* measure = [measures objectAtIndex:i];
        if(!measure.anyNotesInsubdivision)
            [measure changeSubDivision:subdivision];
    }
}

@end
