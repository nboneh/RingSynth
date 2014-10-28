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
@synthesize num = _num;

-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andNum:(int)num andChannel:(ALChannelSource *)channel_{
    self = [super initWithFrame:frame];
    if(self){
        channel = channel_;
        _staff = staff;
        _widthPerNoteHolder = frame.size.width/3;
        _num = num;
        _initialNotesHolder = [[NotesHolder alloc] initWithStaff:staff  andFrame:CGRectMake(0, 0, _widthPerNoteHolder, self.frame.size.height) andTitle:[@(num+ 1) stringValue] andChannel:channel];
        [self addSubview:_initialNotesHolder];
        _currentSubdivision = quaters;
        [self changeSubDivision:_currentSubdivision];
        _initialNotesHolder.titleView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [_initialNotesHolder.titleView addGestureRecognizer:singleFingerTap];
        _noteHolders = [[NSMutableArray alloc] init];
        [_noteHolders addObject:_initialNotesHolder];
        
        
    }
    return self;
}

-(void)changeSubDivision:(Subdivision)subdivision{
    _currentSubdivision = subdivision;
    NotesHolder *notesHolder1;
    NotesHolder *notesHolder2;
    NotesHolder *notesHolder3;
    NSInteger size = _noteHolders.count;
    if(size > 1)
        notesHolder1  = [_noteHolders objectAtIndex:1];
    if(size > 2)
        notesHolder2  = [_noteHolders objectAtIndex:2];
    if(size > 3)
        notesHolder3 = [_noteHolders objectAtIndex:3];
    int x1 =0;
    int x2=0;
    int x3 =0;
    [notesHolder1 setHidden:YES];
    [notesHolder2 setHidden:YES];
    [notesHolder3 setHidden:YES];
    CGRect frame ;
    int height = self.frame.size.height;
    switch(subdivision){
        case quaters:
            break;
        case sixteenths:
            
        case eighths:
            x1 = self.frame.size.width/2;
            if(!notesHolder1){
                notesHolder1 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x1,0, _widthPerNoteHolder,height) andTitle:@"&" andChannel:channel];
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
            
            
            if(_currentSubdivision == eighths)
                break;
            
            x2 = 3*self.frame.size.width/4;
            x3 = self.frame.size.width/4;
            
            if(!notesHolder2){
                notesHolder2 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x2,0, _widthPerNoteHolder,height)andTitle:@"a" andChannel:channel];
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
                notesHolder3 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x3,0, _widthPerNoteHolder,height) andTitle:@"e" andChannel:channel];
                [_noteHolders addObject:notesHolder3 ];
                [self addSubview:notesHolder3];
            }
            else{
                notesHolder3.titleView.text = @"e";
                frame = notesHolder3.frame;
                frame.origin.x = x3;
                notesHolder3.frame = frame;
                [notesHolder3 setHidden:NO];
            }
            
            break;
            
        case triplets:
            x1 = self.frame.size.width/3;
            x2 = 2 *(self.frame.size.width/3);
            if(!notesHolder1){
                notesHolder1 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x1,0, _widthPerNoteHolder,height) andTitle:@"trip" andChannel:channel];
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
                notesHolder2 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x2,0, _widthPerNoteHolder,height) andTitle:@"let" andChannel:channel];
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
    for(int i =1; i < size; i++){
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
    currentPlayingNoteHolder =0;
    playTimer =[NSTimer scheduledTimerWithTimeInterval:time
                                                target:self
                                              selector:@selector(playNoteHolder:)
                                              userInfo:nil
                                               repeats:YES];
    [playTimer fire];
}

-(void)playNoteHolder:(NSTimer *)target{
    if(prevNoteHolder){
        [prevNoteHolder.titleView setTextColor:[UIColor blackColor]];
        [prevNoteHolder.lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dashed"]]];
    }
    
    NotesHolder* notesHolder;
    if(currentPlayingNoteHolder < (_currentSubdivision +1)){
        notesHolder = [_noteHolders objectAtIndex:currentPlayingNoteHolder];
        [ notesHolder play];
        [notesHolder.titleView setTextColor:self.tintColor];
        [notesHolder.lineView setBackgroundColor:self.tintColor];
        prevNoteHolder = notesHolder;
    } else{
        [self stop];
        return;
    }
    
    if(_currentSubdivision == sixteenths){
        switch(currentPlayingNoteHolder){
            case 0:
                currentPlayingNoteHolder = 3;
                break;
            case 3:
                currentPlayingNoteHolder = 1;
                break;
            case 1:
                currentPlayingNoteHolder = 2;
                break;
            case 2:
                currentPlayingNoteHolder = 4;
                break;
        }
    } else {
        currentPlayingNoteHolder++;
    }
    
}

-(void)stop{
    [playTimer invalidate];
    playTimer = nil;
    prevNoteHolder = nil;
    for(NotesHolder * notesHolder in _noteHolders){
        [notesHolder.titleView setTextColor:[UIColor blackColor]];
        [notesHolder.lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dashed"]]];
    }
}

-(NotesHolder *)findNoteHolderAtX:(int)x{
    NSInteger size =[_noteHolders count];
    for(int i = 0; i < size; i++){
        NotesHolder *notesHolder;
        notesHolder = [_noteHolders objectAtIndex:i];
        int xPos = notesHolder.frame.origin.x;
        if(x >= xPos && x <= (xPos + _widthPerNoteHolder)){
            if(!notesHolder.isHidden){
                return notesHolder;
            }
        }
        
        
    }
    return nil;
}
-(NSDictionary*)createSaveFile{
    NSMutableDictionary *preSaveFile = [[NSMutableDictionary alloc] init];
    [preSaveFile setValue:[NSNumber numberWithInt:self.currentSubdivision] forKey:@"subdivision"];
    NSMutableArray*preSaveNoteHolders = [[NSMutableArray alloc] init];
    if(_currentSubdivision == sixteenths){
        //We are going to align the sixteenth note array normally to make the encoding wav file process easier
        [preSaveNoteHolders insertObject:[[_noteHolders objectAtIndex:0] createSaveFile] atIndex:0] ;
        [preSaveNoteHolders insertObject:[[_noteHolders objectAtIndex:3] createSaveFile] atIndex:1] ;
        [preSaveNoteHolders insertObject:[[_noteHolders objectAtIndex:1] createSaveFile] atIndex:2] ;
        [preSaveNoteHolders insertObject:[[_noteHolders objectAtIndex:2] createSaveFile] atIndex:3] ;
    }
    else{
        for(int i = 0; i<  (_currentSubdivision +1); i++){
            [preSaveNoteHolders addObject:[[_noteHolders objectAtIndex:i] createSaveFile]];
        }
    }
    [preSaveFile setValue:[[NSArray alloc] initWithArray:preSaveNoteHolders] forKey:@"notesholders"];
    return [[NSDictionary alloc] initWithDictionary:preSaveFile];
}

-(void)loadSaveFile:(NSDictionary *)saveFile{
    [self changeSubDivision:[[saveFile objectForKey:@"subdivision"] intValue]];
    NSArray * loadNotesHolders = [saveFile objectForKey:@"notesholders"];
    if(_currentSubdivision == sixteenths){
        [[_noteHolders objectAtIndex:0] loadSaveFile:[loadNotesHolders objectAtIndex:0]];
        [[_noteHolders objectAtIndex:3] loadSaveFile:[loadNotesHolders objectAtIndex:1]];
        [[_noteHolders objectAtIndex:1] loadSaveFile:[loadNotesHolders objectAtIndex:2]];
        [[_noteHolders objectAtIndex:2] loadSaveFile:[loadNotesHolders objectAtIndex:3]];
    }
    else{
    for(int i =0; i < [loadNotesHolders count]; i++){
        [[_noteHolders objectAtIndex:i] loadSaveFile:[loadNotesHolders objectAtIndex:i]];
    }
    }
}
@end
