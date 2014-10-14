//
//  NoteHolder.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Measure.h"
#import "Assets.h"


@interface Measure()
-(int) findNoteIfExistsAtY:(int)y;
-(void)checkViews;
-(void)moveNoteAtY:(int) y;
@end

@implementation Measure
static int const WIDTH = 20;
-(id) initWithStaff:(Staff *)staff andEnv: (DetailViewController *) env andX:(int)x{
    self = [super init];
    if(self){
        _env = env;
        _staff = staff;
        volumeMeterHeight = (env.bottomBar.frame.origin.y + staff.spacePerNote - (_staff.frame.origin.y  + _staff.frame.size.height));
        self.frame = CGRectMake(x, _staff.frame.origin.y,  WIDTH, _staff.frame.size.height + volumeMeterHeight);
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, 2,  _staff.frame.size.height -staff.spacePerNote *1.5)];
        [_lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dashed"]]];
        [_lineView setAlpha:0.2f];
        [self addSubview:_lineView];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

-(void)checkViews{
    if(!_noteHolders)
        _noteHolders = [[NSMutableArray alloc] init];
    if(!_volumeSlider){
        _volumeSlider = [[UISlider alloc] init];
        [_volumeSlider removeConstraints:_volumeSlider.constraints];
        [_volumeSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
        _volumeSlider.transform=CGAffineTransformRotate(_volumeSlider.transform,270.0/180*M_PI);
        int sliderWidth = 30;
        _volumeSlider.frame = CGRectMake(self.frame.size.width/2 -sliderWidth/2 +1 ,  _lineView.frame.size.height +_staff.spacePerNote/2 , sliderWidth, volumeMeterHeight);
        [_volumeSlider  setThumbImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
        [_volumeSlider setValue:0.75f];
        [self addSubview:_volumeSlider];
    }
    if(_noteHolders.count >0)
        [_volumeSlider setHidden:NO];
    else
        [_volumeSlider setHidden:YES];
}

-(void)turnOnNoteAtY:(int)y{
    Instrument *instrument = nil;
    
    if(_env.noteBeingMoved)
       instrument = _env.noteBeingMoved.instrument;
    else
        instrument = _env.currentInstrument;
    
    if(!instrument)
        return;
    int pos = round(y/(self.staff.spacePerNote + 0.0));
    if(pos >=  [_staff.notePlacements count]  )
        return;
    [self checkViews];
    
    NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
    Note *note = [[Note alloc] initWithNotePlacement:placement withInstrument:instrument andAccedintal:_env.currentAccidental];
    [_noteHolders  addObject: note];
    [self addSubview:note];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    int y = location.y;
    switch(_env.currentEditMode){
        case insert:
            [self turnOnNoteAtY:y];
            break;
        case modify:
            //For quick changing of accidental
            [self moveNoteAtY:y];
            [self turnOnNoteAtY:y];
            _env.noteBeingMoved = nil;
            break;
        case nerase:
            [self deleteNoteIfExistsAtY:y];
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
-(void)moveNoteAtY:(int) y{
    _env.noteBeingMoved = [self deleteNoteIfExistsAtY:y];
    if(_env.noteBeingMoved ){
        [_env.noteBeingMoved drawAccidental:_env.currentAccidental];
    }
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
@end
