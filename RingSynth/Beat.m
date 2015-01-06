//
//  Beat.m
//  RingSeq
//
//  Created by Nir Boneh on 10/16/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Beat.h"
#import "NotesHolder.h"

@implementation Beat
@synthesize delegate = _delegate;
@synthesize num = _num;
@synthesize noteHolders = _noteHolders;

-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andNum:(int)num andChannel:(ALChannelSource *)channel_{
    self = [super initWithFrame:frame];
    if(self){
        channel = channel_;
        _staff = staff;
        _widthPerNoteHolder = frame.size.width/3;
        _num = num;
        _initialNotesHolder = [[NotesHolder alloc] initWithStaff:staff  andFrame:CGRectMake(0, 0, _widthPerNoteHolder, self.frame.size.height) andTitle:[@(num+ 1) stringValue] andChannel:channel];
        [self addSubview:_initialNotesHolder];
        _initialNotesHolder.titleView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [_initialNotesHolder.titleView addGestureRecognizer:singleFingerTap];
        _noteHolders = [[NSMutableArray alloc] init];
        [_noteHolders addObject:_initialNotesHolder];
        _currentSubdivision = sixteenths;
        [self changeSubDivision:_currentSubdivision];
        
        
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
        case sixteenths:
            x1 = self.frame.size.width/4;
            if(!notesHolder1){
                notesHolder1 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x1,0, _widthPerNoteHolder,height) andTitle:@"e" andChannel:channel];
                [_noteHolders addObject:notesHolder1 ];
                [self addSubview:notesHolder1];
            }
            else{
                notesHolder1.titleView.text = @"e";
                frame = notesHolder1.frame;
                frame.origin.x = x1;
                notesHolder1.frame = frame;
                [notesHolder1 setHidden:NO];
            }
            
            x2 = self.frame.size.width/2;
            if(!notesHolder2){
                notesHolder2 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x2,0, _widthPerNoteHolder,height) andTitle:@"&" andChannel:channel];
                [_noteHolders addObject:notesHolder2];
                [self addSubview:notesHolder2];
            }
            else{
                notesHolder2.titleView.text = @"&";
                frame = notesHolder2.frame;
                frame.origin.x = x2;
                notesHolder2.frame = frame;
                [notesHolder2 setHidden:NO];
            }
            
            
            
            x3 = 3*self.frame.size.width/4;
            
            if(!notesHolder3){
                notesHolder3 = [[NotesHolder alloc] initWithStaff:_staff andFrame: CGRectMake(x3,0, _widthPerNoteHolder,height)andTitle:@"a" andChannel:channel];
                [_noteHolders addObject:notesHolder3];
                [self addSubview:notesHolder3];
            }
            else{
                notesHolder3.titleView.text = @"a";
                frame = notesHolder3.frame;
                frame.origin.x = x3;
                notesHolder3.frame = frame;
                [notesHolder3 setHidden: NO];
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
        _currentSubdivision = triplets;
    [self changeSubDivision:_currentSubdivision];
    if(_delegate)
        [_delegate changeSubDivision:_currentSubdivision andBeat:self];
    
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

-(void)playWithTempo:(int)bpm tic:(int) tic andTicDivision:(int)ticDivision{
    int beatsInSubdivision = ticDivision/(_currentSubdivision +1);
    if(tic % beatsInSubdivision == 0 ){
        int index  = tic/beatsInSubdivision;
        [self stopHolder];
        _currentlyPlayingHolder  = [_noteHolders objectAtIndex:index];
        [ _currentlyPlayingHolder  play];
        [_currentlyPlayingHolder lightUp];
    }
    
    
}


-(void)stopHolder{
    if(_currentlyPlayingHolder){
        [_currentlyPlayingHolder unLightUp];
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
    
    for(int i = 0; i<  (_currentSubdivision +1); i++){
        [preSaveNoteHolders addObject:[[_noteHolders objectAtIndex:i] createSaveFile]];
    }
    [preSaveFile setValue:[[NSArray alloc] initWithArray:preSaveNoteHolders] forKey:@"notesholders"];
    return [[NSDictionary alloc] initWithDictionary:preSaveFile];
}

-(void)loadSaveFile:(NSDictionary *)saveFile{
    int currentSubdivision =[[saveFile objectForKey:@"subdivision"] intValue];
    BOOL wasEightNotes = NO;
    //Out of range used to have quaters and eigth notes
    if(currentSubdivision < triplets){
        if(currentSubdivision == 1)
            //For backward compatibility
            wasEightNotes = YES;
        currentSubdivision = sixteenths;
    }
    
    
    [self changeSubDivision:currentSubdivision];
    NSArray * loadNotesHolders = [saveFile objectForKey:@"notesholders"];
    if(wasEightNotes){
        [[_noteHolders objectAtIndex:0] loadSaveFile:[loadNotesHolders objectAtIndex:0]];
        [[_noteHolders objectAtIndex:2] loadSaveFile:[loadNotesHolders objectAtIndex:1]];
    }
    else {
        for(int i =0; i < [loadNotesHolders count]; i++){
            [[_noteHolders objectAtIndex:i] loadSaveFile:[loadNotesHolders objectAtIndex:i]];
        }
    }
}

-(void)clear{
    for(NotesHolder * holder in _noteHolders){
        [holder clear];
    }
}
@end
