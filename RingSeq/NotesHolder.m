//
//  NoteHolder.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "NotesHolder.h"
#import "Assets.h"
#import "DetailViewController.h"


@interface NotesHolder()
-(void)checkViews;
@end

@implementation NotesHolder
@synthesize titleView = _titleView;
@synthesize lineView = _lineView;
@synthesize notes = _notes;
-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andTitle:(NSString *)title  andChannel:(  ALChannelSource *)  channel_{
    self = [super initWithFrame:frame];
    if(self){
        channel = channel_;
        _titleViewHeight = staff.frame.origin.y - self.frame.origin.y;
        _volumeMeterHeight = (frame.origin.y + frame.size.height) - (staff.frame.origin.y + staff.frame.size.height);
        _staff = staff;
        
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(1 ,0,frame.size.width -1, _titleViewHeight) ];
        [_titleView setText:title];
        _titleView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleView];
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, _titleViewHeight, 2,  _staff.frame.size.height -staff.spacePerNote *2)];
        
        
        [_lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dashed"]]];
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:title];
        if([alphaNums isSupersetOfSet:inStringSet] ){
            [_lineView setAlpha:0.8f];
            [_titleView setAlpha: 0.8f];
        } else{
            [_lineView setAlpha:0.2f];
            [_titleView setAlpha: 0.2f];
        }
        [self addSubview:_lineView];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
    }
    return self;
}

-(void)checkViews{
    if(!_volumeSlider){
        _volumeSlider = [[UISlider alloc] init];
        [_volumeSlider removeConstraints:_volumeSlider.constraints];
        [_volumeSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
        _volumeSlider.frame = CGRectMake(self.frame.size.width/2 -_volumeMeterHeight/2+1 , _titleViewHeight + _lineView.frame.size.height +15, _volumeMeterHeight-2  , _volumeMeterHeight);
        _volumeSlider.transform=CGAffineTransformRotate(_volumeSlider.transform,270.0/180*M_PI);
        [_volumeSlider  setThumbImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
        [_volumeSlider setValue:0.75f];
        _volumeSlider.maximumValue = 1.05f;
        [_volumeSlider addTarget:self
                          action:@selector(sliderViewChange:)
                forControlEvents:UIControlEventValueChanged];
        [self addSubview:_volumeSlider];
    }
    if(_notes.count >0)
        [_volumeSlider setHidden:NO];
    else
        [_volumeSlider setHidden:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    int y = location.y;
    [self placeNoteAtY:y];
}


-(Note *)deleteNoteIfExistsAtY:(int) y{
    NSInteger size =[_notes count];
    for(int i = 0; i < size; i++){
        Note * note = [_notes objectAtIndex:i];
        int yPos = note.frame.origin.y;
        if(y >= yPos && y <= yPos + note.frame.size.height){
            Note *note = [_notes objectAtIndex:i];
            [note removeFromSuperview];
            [_notes removeObjectAtIndex:i];
            [self checkViews];
            [Assets playEraseSound];
            return note;
        }
    }
    return nil;
}

-(void)placeNoteAtY:(int)y {
    
    if(![DetailViewController CURRENT_INSTRUMENT]){
        return;
    }
    y -=_titleViewHeight;
    int pos = round(y /(self.staff.spacePerNote + 0.0f));
    if(pos >=  [_staff.notePlacements count]  )
        return;
    NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
    Note *note = [[Note alloc] initWithNotePlacement:placement withInstrument:[DetailViewController CURRENT_INSTRUMENT] andAccedintal:[DetailViewController CURRENT_ACCIDENTAL]];
    if([self insertNote:note])
        [note playWithVolume:[_volumeSlider value] andChannel:channel];
}

-(BOOL)insertNote:(Note *)note{
    if(!_notes)
        _notes = [[NSMutableArray alloc] init];
    //If equals a note that exists do not add
    NSInteger size =  _notes.count;
    for(int i = 0; i < size; i++){
        Note *note2 = [_notes objectAtIndex:i];
        if([note2 equals:note])
            return NO;
    }
    CGRect frame = note.frame;
    frame.origin.y += _volumeMeterHeight;
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
    note.frame = frame;
    [_notes  addObject: note];
    [self checkViews];
    [self addSubview:note];
    UITapGestureRecognizer *doubleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDoubleTap:)];
    [doubleFingerTap setNumberOfTapsRequired:2];
    [note addGestureRecognizer:doubleFingerTap];
    return YES;

}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    Note * note = (Note *)recognizer.view;
    if(note.accidental < (numOfAccedintals -1))
        note.accidental++;
    else
        note.accidental = 0;
    [note playWithVolume:[_volumeSlider value] andChannel:channel];
    
}

- (void)longPress:(UITapGestureRecognizer *)recognizer {
    Note * note = (Note *)recognizer.view;
    [note removeFromSuperview];
    [_notes removeObject:note];
    [self checkViews];
    [Assets playEraseSound];
    
}

-(BOOL)anyNotesInNoteHolder{
    return [_notes count];
}
-(void)play{
    for(Note *note in _notes){
        [note playWithVolume:[_volumeSlider value] andChannel:channel];
    }
}

-(void)sliderViewChange:(UISlider *)sender{
    if ([sender value] > 1.0f) {
        [sender setValue:1.0f];
    }
}

-(NSDictionary*)createSaveFile{
    NSMutableDictionary *preSaveFile = [[NSMutableDictionary alloc] init];
    if([_notes count] >0){
        [preSaveFile setValue:[NSNumber numberWithFloat:_volumeSlider.value] forKey:@"volume"];
        NSMutableArray*preSaveNotes = [[NSMutableArray alloc] init];
        for(Note*note in _notes ){
            NSMutableDictionary *preSaveNote = [[NSMutableDictionary alloc] init];
            [preSaveNote setValue:[NSNumber numberWithInt:(int)[[Assets INSTRUMENTS] indexOfObject:note.instrument]] forKey:@"instrument"];
            [preSaveNote setValue:[NSNumber numberWithInt:(int)[_staff.notePlacements indexOfObject:note.notePlacement]] forKey:@"noteplacement"];
            [preSaveNote setValue:[NSNumber numberWithInt: note.accidental] forKey:@"accidental"];
            [preSaveNotes addObject:preSaveNote];
        }
        [preSaveFile setValue:[[NSArray alloc] initWithArray:preSaveNotes] forKey:@"notes"];
    }
    return [[NSDictionary alloc] initWithDictionary:preSaveFile];
}

-(void)loadSaveFile:(NSDictionary *)saveFile{
    if([saveFile objectForKey:@"volume" ]){
        NSArray *loadNotes = [saveFile objectForKey:@"notes"];
        for(NSDictionary * noteDict in loadNotes){
            Note*note = [[Note alloc] initWithNotePlacement:[_staff.notePlacements objectAtIndex:[[noteDict objectForKey:@"noteplacement"] intValue]]
                                             withInstrument:[[Assets INSTRUMENTS] objectAtIndex:[[noteDict objectForKey:@"instrument"] intValue]] andAccedintal:[[noteDict  objectForKey:@"accidental"] intValue]];
            [self insertNote:note];

        }
        [self checkViews];

         _volumeSlider.value = [[saveFile objectForKey:@"volume"] floatValue];
    }
}
@end
