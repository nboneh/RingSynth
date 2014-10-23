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
@synthesize numOfMeasures = _numOfMeasures;
-(id) initWithStaff:(Staff *)staff_ andFrame:(CGRect)frame andNumOfMeasure:(int)numOfMeasures{
    self = [super init];
    if(self){
        staff = staff_;
        measures = [[NSMutableArray alloc] init];
        channel =[[ALChannelSource alloc] initWithSources:kDefaultReservedSources];
        _numOfMeasures = numOfMeasures;
        
        _widthFromFirstMeasure = staff.trebleView.frame.size.width;
        int delX =_widthFromFirstMeasure;
        _widthPerMeasure = frame.size.width/4;
        for(int i = 0; i < numOfMeasures; i++){
            Measure* measure =[[Measure alloc] initWithStaff:staff andFrame:CGRectMake(delX, 0, _widthPerMeasure, frame.size.height) andNum:(i) andChannel:channel];
            [measures addObject:measure];
            delX += _widthPerMeasure;
            [self addSubview:measure];
            [measure setDelegate:self];
            
        }
        self.frame = CGRectMake(0, 0,  _widthPerMeasure * numOfMeasures + _widthFromFirstMeasure,frame.size.height);
        _currentMeasurePlaying = 0;
        self.clipsToBounds = YES;
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
    if(_currentMeasurePlaying >= _numOfMeasures){
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
     playTimer = nil;
    for(Measure * measure in measures){
        [measure stop];
    }
    _currentMeasurePlaying = 0;
}
-(void)changeSubDivision:(Subdivision)subdivision{
    NSInteger size = _numOfMeasures ;
    for(int i = 0; i < size; i++){
        Measure* measure = [measures objectAtIndex:i];
        if(!measure.anyNotesInsubdivision)
            [measure changeSubDivision:subdivision];
    }
}

-(void)setNumOfMeasures:(int)numOfMeasures{
    _numOfMeasures = numOfMeasures;
    CGRect myFrame = self.frame;
    myFrame.size.width = _widthPerMeasure * numOfMeasures + _widthFromFirstMeasure;
    self.frame = myFrame;
    int delX =_widthFromFirstMeasure + (int)[measures count]*(_widthPerMeasure) ;
    for(int i = (int)[measures count]; i < numOfMeasures; i++){
        Measure* measure =[[Measure alloc] initWithStaff:staff andFrame:CGRectMake(delX, 0, _widthPerMeasure, self.frame.size.height) andNum:(i) andChannel:channel];
        [measures addObject:measure];
        [self addSubview:measure];
        delX += _widthPerMeasure;
        [measure setDelegate:self];
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


-(NSArray*)createSaveFile{
    NSMutableArray* preSaveFile = [[NSMutableArray alloc] init];
    for(int i = 0; i < _numOfMeasures; i++){
        [preSaveFile addObject:[(Measure *)[measures objectAtIndex:i] createSaveFile] ];
    }
    return [[NSArray alloc] initWithArray:preSaveFile];
}

-(void)loadSaveFile:(NSArray *)saveFile{
    NSInteger size = saveFile.count;
    for(int i = 0; i < size; i++){
        [(Measure *)[measures objectAtIndex:i] loadSaveFile:[saveFile objectAtIndex:i]];
    }
}
@end
