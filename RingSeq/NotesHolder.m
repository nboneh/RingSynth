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

-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andTitle:(NSString *)title{
    self = [super initWithFrame:frame];
    if(self){

        _titleViewHeight = staff.frame.origin.y - self.frame.origin.y;
        _volumeMeterHeight = (frame.origin.y + frame.size.height) - (staff.frame.origin.y + staff.frame.size.height);
        _staff = staff;

        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0 ,0,frame.size.width, _titleViewHeight) ];
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
        _volumeSlider.frame = CGRectMake(self.frame.size.width/2 -_volumeMeterHeight/2 -2 + 2 , _titleViewHeight + _lineView.frame.size.height +12, _volumeMeterHeight-2  , _volumeMeterHeight);
        _volumeSlider.transform=CGAffineTransformRotate(_volumeSlider.transform,270.0/180*M_PI);
        [_volumeSlider  setThumbImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
        [_volumeSlider setValue:0.75f];
        _volumeSlider.maximumValue = 1.0f;
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
- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer  {
    //Long press to delete
    [recognizer.view removeFromSuperview];
    [_notes removeObject:recognizer.view];
    [self checkViews];
    [Assets playEraseSound];
    
}




-(void)placeNoteAtY:(int)y {
    if(!_notes)
        _notes = [[NSMutableArray alloc] init];

    if(![DetailViewController CURRENT_INSTRUMENT]){
            return;
    }
    y -=_titleViewHeight;
    int pos = round(y/(self.staff.spacePerNote + 0.0));
    if(pos >=  [_staff.notePlacements count]  )
        return;
    NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
    Note *note = [[Note alloc] initWithNotePlacement:placement withInstrument:[DetailViewController CURRENT_INSTRUMENT] andAccedintal:[DetailViewController CURRENT_ACCIDENTAL]];
    //If equals a note that exists do not add
    NSInteger size =  _notes.count;
    for(int i = 0; i < size; i++){
        Note *note2 = [_notes objectAtIndex:i];
        if([note2 equals:note])
            return;
    }
    CGRect frame = note.frame;
    frame.origin.y += _volumeMeterHeight;
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
    note.frame = frame;
    [_notes  addObject: note];
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    [note addGestureRecognizer:longPress];
    

    [note playWithVolume:[_volumeSlider value]];
    [self addSubview:note];
    [self checkViews];
    
}


-(BOOL)anyNotesInNoteHolder{
    return [_notes count];
}
-(void)play{
    for(Note *note in _notes){
        [note playWithVolume:[_volumeSlider value]];
    }
}
@end
