//
//  Layout.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Layout.h"
#import "DetailViewController.h"


@interface Layout()
//-(void)checkViews;
//-(NotesHolder *)findMeasureIfExistsAtX:(int)x;
@end
@implementation Layout
@synthesize widthFromFirstMeasure = _widthFromFirstMeasure;
@synthesize widthPerMeasure = _widthPerMeasure;
@synthesize currentMeasurePlaying = _currentMeasurePlaying;
-(id) initWithStaff:(Staff *)staff andFrame:(CGRect)frame andNumOfMeasure:(int)numOfMeasures{
    self = [super init];
    if(self){
        NSMutableArray *preMeasures = [[NSMutableArray alloc] init];
                channel =[[ALChannelSource alloc] initWithSources:kDefaultReservedSources];
        
        _widthFromFirstMeasure = staff.trebleView.frame.size.width;
        int delX =_widthFromFirstMeasure;
        _widthPerMeasure = frame.size.width/4;
        for(int i = 0; i < numOfMeasures; i++){
            Measure* measure =[[Measure alloc] initWithStaff:staff andFrame:CGRectMake(delX, 0, _widthPerMeasure, frame.size.height) andNum:(i) andChannel:channel];
            [preMeasures addObject:measure];
            delX += _widthPerMeasure;
            [self addSubview:measure];
            [measure setDelegate:self];
            
        }
        measures = [[NSArray alloc] initWithArray:preMeasures];
        self.frame = CGRectMake(0, 0,  _widthPerMeasure * numOfMeasures + _widthFromFirstMeasure,frame.size.height);
        _currentMeasurePlaying = 0;
    }
    return self;
}

-(void)playWithTempo:(int)bpm_ fromMeasure:(int)measure{
    _currentMeasurePlaying = measure ;
    bpm = bpm_;
    playTimer =[NSTimer scheduledTimerWithTimeInterval:(60.0f/bpm)
                                                target:self
                                              selector:@selector(playMeasure:)
                                              userInfo:nil
                                               repeats:YES];
    [playTimer fire];
    
}
-(void)playMeasure:(NSTimer *)target{
    if(_currentMeasurePlaying >= [measures count]){
        if([DetailViewController LOOPING])
            _currentMeasurePlaying = 0;
        else{
            [self stop];
            return;
        }
            
    }
        
        
        Measure * measure = [measures objectAtIndex:_currentMeasurePlaying];
        [measure playWithTempo:bpm];

    _currentMeasurePlaying++;
}

-(void)stop{
    [playTimer invalidate];
    if(_currentMeasurePlaying < [measures count]){
        Measure * measure = [measures objectAtIndex:_currentMeasurePlaying];
        [measure stop];
    }
    playTimer = nil;
    _currentMeasurePlaying = 0;
}
-(void)changeSubDivision:(Subdivision)subdivision{
    NSInteger size = [measures count];
    for(int i = 0; i < size; i++){
        Measure* measure = [measures objectAtIndex:i];
        if(!measure.anyNotesInsubdivision)
            [measure changeSubDivision:subdivision];
    }
}

-(Measure *)findMeasureAtx:(int)x{
    int pos = (x -_widthFromFirstMeasure)/( _widthPerMeasure);
    if(pos < [measures count])
        return[measures objectAtIndex:pos];
    return nil;
}

-(void)setMuted:(BOOL)abool{
    [channel setMuted:abool];
    if(abool)
        [channel stop];
}

@end
