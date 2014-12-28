//
//  Layout.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Layout.h"


@implementation Layout
@synthesize channel= _channel;
@synthesize widthFromFirstBeat = _widthFromFirstBeat;
@synthesize widthPerBeat = _widthPerBeat;
@synthesize currentBeatPlaying = _currentBeatPlaying;
@synthesize numOfBeats = _numOfBeats;
@synthesize beats =_beats;
-(id) initWithStaff:(Staff *)staff_ andFrame:(CGRect)frame andNumOfBeat:(int)numOfBeats{
    self = [super init];
    if(self){
        staff = staff_;
        _beats = [[NSMutableArray alloc] init];
        _channel =[[ALChannelSource alloc] initWithSources:kDefaultReservedSources];
        _numOfBeats = numOfBeats;
        
        _widthFromFirstBeat = staff.trebleView.frame.size.width;
        int delX =_widthFromFirstBeat;
        _widthPerBeat = frame.size.width/4;
        for(int i = 0; i < numOfBeats; i++){
            Beat* beat =[[Beat alloc] initWithStaff:staff andFrame:CGRectMake(delX, 0, _widthPerBeat, frame.size.height) andNum:(i) andChannel:_channel];
            [_beats addObject:beat];
            delX += _widthPerBeat;
            [self addSubview:beat];
            
        }
        self.frame = CGRectMake(0, 0,  _widthPerBeat * numOfBeats + _widthFromFirstBeat,frame.size.height);
        _currentBeatPlaying = 0;
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)playWithTempo:(int)bpm_ fromBeat:(int)beat{
    if(playTimer)
        [self stop];
    _currentBeatPlaying = beat ;
    bpm = bpm_;
    playTimer =[NSTimer scheduledTimerWithTimeInterval:(60.0f/bpm)
                                                target:self
                                              selector:@selector(playBeat:)
                                              userInfo:nil
                                               repeats:YES];
     [playTimer fire];

    
}
-(void)playBeat:(NSTimer *)target{
    if(_currentBeatPlaying >= _numOfBeats){
            [self stop];
            return;
    }
    
    
    Beat * beat = [_beats objectAtIndex:_currentBeatPlaying];
    [beat playWithTempo:bpm];
    
    _currentBeatPlaying++;
}

-(void)stop{
    [playTimer invalidate];
     playTimer = nil;
    for(Beat * beat in _beats){
        [beat stop];
    }
    _currentBeatPlaying = 0;
}


-(void)setNumOfBeats:(int)numOfBeats{
    _numOfBeats= numOfBeats;
    CGRect myFrame = self.frame;
    myFrame.size.width = _widthPerBeat * numOfBeats + _widthFromFirstBeat;
    self.frame = myFrame;
    int delX =_widthFromFirstBeat + (int)[_beats count]*(_widthPerBeat) ;
    for(int i = (int)[_beats count]; i < numOfBeats; i++){
        Beat* beat =[[Beat  alloc] initWithStaff:staff andFrame:CGRectMake(delX, 0, _widthPerBeat, self.frame.size.height) andNum:(i) andChannel:_channel];
        [_beats addObject:beat];
        [self addSubview:beat];
        delX += _widthPerBeat;
        [beat setDelegate:self];
    }
        
}

-(Beat *)findBeatAtx:(int)x{
    int pos = (x -_widthFromFirstBeat)/( _widthPerBeat);
    if(pos < [_beats count])
        return[_beats objectAtIndex:pos];
    return nil;
}

-(void)setMuted:(BOOL)abool{
    [_channel setMuted:abool];
    if(abool)
        [_channel stop];
}


-(NSArray*)createSaveFile{
    NSMutableArray* preSaveFile = [[NSMutableArray alloc] init];
    for(int i = 0; i < _numOfBeats; i++){
        [preSaveFile addObject:[(Beat  *)[_beats objectAtIndex:i] createSaveFile] ];
    }
    return [[NSArray alloc] initWithArray:preSaveFile];
}

-(void)loadSaveFile:(NSArray *)saveFile{
    NSInteger size = saveFile.count;
    for(int i = 0; i < size; i++){
        [(Beat  *)[_beats objectAtIndex:i] loadSaveFile:[saveFile objectAtIndex:i]];
    }
}
@end
