//
//  Measure.m
//  RingSeq
//
//  Created by Nir Boneh on 10/16/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Measure.h"
#import "NotesHolder.h"

@implementation Measure
@synthesize delegate = _delegate;

-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andNum:(int)num{
    self = [super initWithFrame:frame];
    if(self){
        _staff = staff;
        _widthPerNoteHolder = frame.size.width/3;
        _initialNotesHolder = [[NotesHolder alloc] initWithStaff:staff  andFrame:CGRectMake(0, 0, _widthPerNoteHolder, self.frame.size.height) andTitle:[@(num) stringValue]];
        [self addSubview:_initialNotesHolder];
        _currentSubdivision = quaters;
        [self changeSubDivision:_currentSubdivision];
        _initialNotesHolder.titleView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [_initialNotesHolder.titleView addGestureRecognizer:singleFingerTap];
        
        
    }
    return self;
}

-(void)changeSubDivision:(Subdivision)subdivision{
    _currentSubdivision = subdivision;
    if(_noteHolders == nil)
        _noteHolders = [[NSMutableArray alloc] init];
    NotesHolder *notesHolder1;
    NotesHolder *notesHolder2;
    NotesHolder *notesHolder3;
    NSInteger size = _noteHolders.count;
    if(size > 0)
        notesHolder1  = [_noteHolders objectAtIndex:0];
    if(size > 1)
        notesHolder2  = [_noteHolders objectAtIndex:1];
    if(size > 2)
        notesHolder3 = [_noteHolders objectAtIndex:2];
    int x1;
    int x2;
    int x3;
    [notesHolder1 setHidden:YES];
    [notesHolder2 setHidden:YES];
    [notesHolder3 setHidden:YES];
    CGRect frame ;
    int height = self.frame.size.height;
    switch(subdivision){
        case quaters:
            break;
        case sixteenths:
            x2 = 3*self.frame.size.width/4;
            x3 = self.frame.size.width/4;
            
            if(!notesHolder2){
                notesHolder2 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x2,0, _widthPerNoteHolder,height)andTitle:@"a"];
                [_noteHolders addObject:notesHolder2];
                [self addSubview:notesHolder2];
            }
            else{
                notesHolder2.titleView.text = @"a";
                frame = notesHolder2.frame;
                frame.origin.x = x2;
                notesHolder2.frame = frame;
                [notesHolder2 setHidden: NO];
            }
            
            if(!notesHolder3){
                notesHolder3 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x3,0, _widthPerNoteHolder,height) andTitle:@"e"];
                [_noteHolders addObject:notesHolder3];
                [self addSubview:notesHolder3];
            }
            else{
                notesHolder3.titleView.text = @"e";
                frame = notesHolder3.frame;
                frame.origin.x = x3;
                notesHolder3.frame = frame;
                [notesHolder3 setHidden:NO];
            }
            
            
            
            
        case eighths:
            x1 = self.frame.size.width/2;
            if(!notesHolder1){
                notesHolder1 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x1,0, _widthPerNoteHolder,height) andTitle:@"&"];
                [_noteHolders addObject:notesHolder1];
                [self addSubview:notesHolder1];
            }
            else{
                notesHolder1.titleView.text = @"&";
                frame = notesHolder1.frame;
                frame.origin.x = x1;
                notesHolder1.frame = frame;
                [notesHolder1 setHidden:NO];
            }
            
            
            
            break;
            
        case triplets:
            x1 = self.frame.size.width/3;
            x2 = 2 *(self.frame.size.width/3);
            if(!notesHolder1){
                notesHolder1 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x1,0, _widthPerNoteHolder,height) andTitle:@"trip"];
                [_noteHolders addObject:notesHolder1];
                [self addSubview:notesHolder1];
            }
            else{
                notesHolder1.titleView.text = @"trip";
                frame = notesHolder1.frame;
                frame.origin.x = x1;
                notesHolder1.frame = frame;
                [notesHolder1 setHidden:NO];
            }
            
            if(!notesHolder2){
                notesHolder2 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x2,0, _widthPerNoteHolder,height) andTitle:@"let"];
                [_noteHolders addObject:notesHolder2];
                [self addSubview:notesHolder2];
            }
            else{
                notesHolder2.titleView.text = @"let";
                frame = notesHolder2.frame;
                frame.origin.x = x2;
                notesHolder2.frame = frame;
                [notesHolder2 setHidden:NO];
            }
            
            
            break;
        case numOfSubdivisions:
            break;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    _currentSubdivision++;
    if(_currentSubdivision >= numOfSubdivisions)
        _currentSubdivision = 0;
    [self changeSubDivision:_currentSubdivision];
    if(_delegate)
        [_delegate changeSubDivision:_currentSubdivision];
    
}
-(BOOL)anyNotesInsubdivision{
    NSInteger size = _noteHolders.count;
    for(int i =0; i < size; i++){
        NotesHolder* noteHolder =  [_noteHolders objectAtIndex:i];
        if([noteHolder anyNotesInNoteHolder])
            return YES;
    }
    return NO;
}

-(BOOL)anyNotes{
    return [self anyNotesInsubdivision] && [_initialNotesHolder anyNotesInNoteHolder];
}

-(void)playWithTempo:(int)bpm{

    float time = (60.0f/bpm)/(_currentSubdivision+1);
    currentPlayingNoteHolder =-1;
    playTimer =[NSTimer scheduledTimerWithTimeInterval:time
                                                target:self
                                              selector:@selector(playNoteHolder:)
                                              userInfo:nil
                                               repeats:YES];
    [ _initialNotesHolder play];
    [_initialNotesHolder setBackgroundColor:self.tintColor];
}

-(void)playNoteHolder:(NSTimer *)target{
    if(currentPlayingNoteHolder < 0){
        [_initialNotesHolder setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    }
    else if(currentPlayingNoteHolder < [_noteHolders count]){
        NotesHolder* notesHolder = [_noteHolders objectAtIndex:currentPlayingNoteHolder];
        [notesHolder setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.0f]];
    } else{
        [self stop];
    }

    switch(_currentSubdivision){
        case quaters:
            [self stop];
            return;
        case sixteenths:
            switch(currentPlayingNoteHolder){
                case -1:
                    currentPlayingNoteHolder = 2;
                    break;
                case 2:
                    currentPlayingNoteHolder = 0;
                    break;
                case 0:
                    currentPlayingNoteHolder = 1;
                    break;
                case 1:
                    [self stop];
                    return;
            }
            break;
            
        case eighths:
            if(currentPlayingNoteHolder >= 0){
                [self stop];
                return;
            }
             currentPlayingNoteHolder++;
            break;
            
        case triplets:
            if(currentPlayingNoteHolder >= 1){
                [self stop];
                return;
            }
            currentPlayingNoteHolder++;
            break;
        case numOfSubdivisions:
            [self stop];
            return;
    }
    NotesHolder* notesHolder = [_noteHolders objectAtIndex:currentPlayingNoteHolder];
    [notesHolder play];
    [notesHolder setBackgroundColor:self.tintColor];
}

-(void)stop{
    [playTimer invalidate];
    playTimer = nil;
}

@end
