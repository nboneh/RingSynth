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
static int const titleViewSize =20;
-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env x:(int)x
           andTitle:(NSString *)title{
    self = [super init];
    if(self){
        _env = env;
        _staff = staff;
        volumeMeterHeight = (env.bottomBar.frame.origin.y + staff.spacePerNote - (_staff.frame.origin.y  + _staff.frame.size.height));
        self.frame = CGRectMake(x, _staff.frame.origin.y,  WIDTH, _staff.frame.size.height + volumeMeterHeight);
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -titleViewSize/4 ,-titleViewSize, self.frame.size.width, titleViewSize) ];
        [titleView setText:title];
        [self addSubview:titleView];
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, 2,  _staff.frame.size.height -staff.spacePerNote *1.5)];
        [_lineView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dashed"]]];
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:title];
        if([alphaNums isSupersetOfSet:inStringSet] ){
            if((title.integerValue -1) % 4 == 0){
                [_lineView setAlpha:0.8f];
                [titleView setAlpha: 0.8f];
            }
            else{
                [_lineView setAlpha:0.5f];
                [titleView setAlpha: 0.5f];
                
            }
        } else{
            [_lineView setAlpha:0.2f];
            [titleView setAlpha: 0.2f];
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
@end
