//
//  NoteHolder.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Measure.h"
#import "Assets.h"

@implementation Note
const int WIDTH = 80;

-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument andAccedintal:(Accidental)accidental{
    self = [super init];
    if(self){
        _instrument = instrument;
        _noteDescription = [placement.noteDescs objectAtIndex:accidental];
        UIImageView *instrImage = [[UIImageView alloc] initWithImage:[instrument getImage]];
        [instrImage setTintColor:self.tintColor];
        CGRect imageFrame = instrImage.frame;
        self.frame = CGRectMake(WIDTH/2- imageFrame.size.width/2, placement.y - imageFrame.size.height/2, imageFrame.size.width, imageFrame.size.height);
        [self addSubview:instrImage];
        
        
        if(_noteDescription.accidental == sharp || _noteDescription.accidental == flat ){
            CGRect myFrame = self.frame;
            int width = myFrame.size.width/2;
            UILabel *accedintalView= [[UILabel alloc] initWithFrame:CGRectMake(-width * .8f,width/2,width,width)];
            accedintalView.textColor = self.tintColor;
            [self addSubview:accedintalView];
            if(_noteDescription.accidental == sharp)
                accedintalView.text = @"#";
            else
                accedintalView.text = @"b";
            [self addSubview:accedintalView];
        }
        [self play];
        
    }
    return self;
}
-(void) play{
    
}

@end

@interface Measure()
-(int) findNoteIfExistsAtY:(int)y;
@end

@implementation Measure
-(id) initWithStaff:(Staff *)staff andEnv: (DetailViewController *) env andX:(int)x{
    self = [super init];
    if(self){
        _env = env;
        _staff = staff;
        ;
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


-(void)turnOnNoteAtY:(int)y{
    Instrument *instrument = _env.currentInstrument;
    int pos = y/self.staff.spacePerNote;
    
    if(instrument && pos < [_staff.notePlacements count] ){
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
        [_volumeSlider setHidden:NO];
        
        NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
        Note *note = [[Note alloc] initWithNotePlacement:placement withInstrument:instrument andAccedintal:_env.currentAccidental];
        [_noteHolders  addObject: note];
        [self addSubview:note];
    }
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    int y = location.y;
    switch(_env.currentEditMode){
        case insert:
            [self turnOnNoteAtY:y];
            break;
        case modify:
            ;
        case erase:
            [self deleteNoteIfExistsAtY:y];
    }
}

-(Note *)deleteNoteIfExistsAtY:(int) y{
    int index =[self findNoteIfExistsAtY:y];
    if(index >= 0 && index < [_noteHolders count]){
        Note *note = [_noteHolders objectAtIndex:index];
        [note removeFromSuperview];
        [_noteHolders removeObjectAtIndex:index];
        return note;
    }
    return nil;
}
-(void)moveNote:(int) y{
    int index =[self findNoteIfExistsAtY:y];
    if(index >= 0 && index < [_noteHolders count]){
        noteBeingMoved = [_noteHolders objectAtIndex: index];
        
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
