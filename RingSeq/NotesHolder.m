//
//  NoteHolder.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "NotesHolder.h"
#import "Assets.h"


@interface NotesHolder()
-(void)checkViews;
-(int) findNoteIfExistsAtY:(int)y;
@end

@implementation NotesHolder
static int const WIDTH = 40;
static int const TITLE_VIEW_HEIGHT =30;
static const int VOLUME_METER_HEIGHT = 30;
@synthesize titleView = _titleView;

-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env x:(int)x
           andTitle:(NSString *)title{
    self = [super init];
    if(self){
        _env = env;
        _staff = staff;
        self.frame = CGRectMake(x, 0,  WIDTH, _staff.frame.size.height + VOLUME_METER_HEIGHT +TITLE_VIEW_HEIGHT);
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -15 ,0,30, TITLE_VIEW_HEIGHT) ];
        [_titleView setText:title];
        _titleView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleView];
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, TITLE_VIEW_HEIGHT, 2,  _staff.frame.size.height -staff.spacePerNote *2)];
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
        _volumeSlider.frame = CGRectMake(self.frame.size.width/2 -VOLUME_METER_HEIGHT/2 , TITLE_VIEW_HEIGHT + _lineView.frame.size.height +13, VOLUME_METER_HEIGHT +1 , VOLUME_METER_HEIGHT +1);
      _volumeSlider.transform=CGAffineTransformRotate(_volumeSlider.transform,270.0/180*M_PI);
        [_volumeSlider  setThumbImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
        [_volumeSlider setValue:0.75f];
        [self addSubview:_volumeSlider];
    }
    if(_noteHolders.count >0)
        [_volumeSlider setHidden:NO];
    else
        [_volumeSlider setHidden:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    int y = location.y;
    switch(_env.currentEditMode){
        case insert:
            [self placeNoteAtY:y fromExistingNote:nil];
            break;
        case nerase:
            if([self deleteNoteIfExistsAtY:y])
                [Assets playEraseSound];
            break;
    }
}


-(Note *)deleteNoteIfExistsAtY:(int) y{
    int index =[self findNoteIfExistsAtY:y];
    if(index >= 0 && index < [_noteHolders count]){
        Note *note = [_noteHolders objectAtIndex:index];
        [note removeFromSuperview];
        [_noteHolders removeObjectAtIndex:index];
        [self checkViews];
        return note;
    }
    return nil;
}

-(void)placeNoteAtY:(int)y fromExistingNote:(Note*)note {
    if(!_noteHolders)
        _noteHolders = [[NSMutableArray alloc] init];
    Instrument * instrument;
    if(!note){
        instrument = _env.currentInstrument;
        if(!instrument)
            return;
    }
    y -=TITLE_VIEW_HEIGHT;
    int pos = round(y/(self.staff.spacePerNote + 0.0));
    if(pos >=  [_staff.notePlacements count]  )
        return;
    NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
    if(!note)
        note = [[Note alloc] initWithNotePlacement:placement withInstrument:instrument andAccedintal:_env.currentAccidental];
    //If equals a note that exists do not add
    NSInteger size =  _noteHolders.count;
    for(int i = 0; i < size; i++){
        Note *note2 = [_noteHolders objectAtIndex:i];
        if([note2 equals:note])
            return;
    }
    CGRect frame = note.frame;
    frame.origin.y += TITLE_VIEW_HEIGHT;
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
    note.frame = frame;
    [_noteHolders  addObject: note];
    [self addSubview:note];
    [self checkViews];
    
}


-(int)findNoteIfExistsAtY:(int)y{
    NSInteger size =[_noteHolders count];
    for(int i = 0; i < size; i++){
        Note * note = [_noteHolders objectAtIndex:i];
        int yPos = note.frame.origin.y;
        if(y >= yPos && y <= yPos + note.frame.size.height)
            return i;
        
    }
    return -1;
}

-(BOOL)anyNotesInNoteHolder{
    return [_noteHolders count];
}

+(int)VOLUME_METER_HEIGHT{
    return VOLUME_METER_HEIGHT;
}
+(int)TITLE_VIEW_HEIGHT{
    return TITLE_VIEW_HEIGHT;
}
@end
