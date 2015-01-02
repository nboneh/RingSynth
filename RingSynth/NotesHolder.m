//
//  NoteHolder.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "NotesHolder.h"
#import "Assets.h"
#import "Drums.h"
#import "MusicViewController.h"


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
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:title];
        bold = [alphaNums isSupersetOfSet:inStringSet];
        [self unLightUp];
        [self addSubview:_lineView];

        
    }
    return self;
}

-(void)checkViews{
    if(!_volumeSlider){
        _volumeSlider = [[UISlider alloc] init];
        [_volumeSlider removeConstraints:_volumeSlider.constraints];
        [_volumeSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
        int pushDown = 15;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            pushDown = 40;
        _volumeSlider.frame = CGRectMake(self.frame.size.width/2 -_volumeMeterHeight/2+1 , _titleViewHeight + _lineView.frame.size.height +pushDown, _volumeMeterHeight-2  , _volumeMeterHeight);
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
    
    if(![MusicViewController CURRENT_INSTRUMENT]){
        return;
    }
    y -=_titleViewHeight;
    int pos = round(y /(self.staff.spacePerNote + 0.0f));
    if(pos >=  [_staff.notePlacements count]  )
        return;
    NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
    Note *note = [[Note alloc] initWithNotePlacement:placement withInstrument:[MusicViewController CURRENT_INSTRUMENT] andAccedintal:[MusicViewController CURRENT_ACCIDENTAL]];
    if([self insertNote:note])
        [note playWithVolume:[_volumeSlider value]];
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
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2 + self.superview.frame.origin.x + self.frame.origin.x;
    note.frame = frame;
    [_notes  addObject: note];
    [self checkViews];
    [_staff.superview addSubview:note];
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
    [note playWithVolume:[_volumeSlider value]];
    
}



-(BOOL)anyNotesInNoteHolder{
    return [_notes count];
}
-(void)play{
    if(_notes.count == 0)
        return;
    ALChannelSource *mainChannel = [[OALSimpleAudio sharedInstance] channel];
    [OALSimpleAudio sharedInstance].channel = channel;
    Instrument * instrument = [(Note *)[_notes objectAtIndex:0] instrument];
    //Drums is the only instrument that is allowed to bleed into itself
    if( ![instrument isKindOfClass:[Drums class] ]|| _volumeSlider.value == 0 )
    [[OALSimpleAudio sharedInstance] stopAllEffects];
    for(Note *note in _notes){
        [note playWithVolume:[_volumeSlider value]];
    }
    [OALSimpleAudio sharedInstance].channel = mainChannel;
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
            [preSaveNote setValue:[Assets objectForInst:note.instrument] forKey:@"instrument"];
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
                                             withInstrument:[Assets instForObject:[noteDict objectForKey:@"instrument"]]  andAccedintal:[[noteDict  objectForKey:@"accidental"] intValue]];
            [self insertNote:note];

        }
        [self checkViews];

         _volumeSlider.value = [[saveFile objectForKey:@"volume"] floatValue];
    }
}

-(void)unLightUp{
    if(bold ){
        [_lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Dashed Dark"] ]];

        [_titleView setTextColor:[UIColor blackColor]];
    } else{
        [_lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Dashed Light"] ]];
        [_titleView setTextColor:[UIColor lightGrayColor]];
    }
}

-(void)lightUp{
    [_lineView setAlpha:1];
    [_titleView setAlpha:1];
    [ _titleView setTextColor:self.tintColor];
    [ _lineView setBackgroundColor:self.tintColor];

}

-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    for(Note *note in _notes){
        [note setHidden:hidden];
        
    }

}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //Updating notes frames
    for(Note *note in _notes){
        CGRect frame = note.frame;
        frame.origin.x = self.frame.size.width/2 - frame.size.width/2 + self.superview.frame.origin.x + self.frame.origin.x;
        note.frame = frame;

    }
}
@end
