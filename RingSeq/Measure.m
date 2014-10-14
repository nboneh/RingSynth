//
//  NoteHolder.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Measure.h"

@implementation Note
const int WIDTH = 80;

-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument{
    self = [super init];
    if(self){
        _instrument = instrument;
        _noteDescription = placement.noteDesc;
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

@implementation Measure

-(id) initWithStaff:(Staff *)staff  andX:(int)x andVolumeMeterHeight:(int)volumeMeterHeight_{
    self = [super init];
    if(self){
        _staff = staff;
         volumeMeterHeight = volumeMeterHeight_;
        self.frame = CGRectMake(x, _staff.frame.origin.y,  WIDTH, _staff.frame.size.height + volumeMeterHeight_);
       _lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 0, 2,  _staff.frame.size.height -staff.spacePerNote *1.5)];
        [_lineView setBackgroundColor:[UIColor blackColor]];
        [self addSubview:_lineView];
    }
    return self;
}
-(void)turnOnNoteAtPos:(int)pos withInstrument:(Instrument *)instrument
        withAccedintal:(Accidental) accedintal{
    if(!_noteHolders)
        _noteHolders = [[NSMutableArray alloc] init];
    NotePlacement * placement =[[_staff notePlacements] objectAtIndex:pos];
    placement.noteDesc.accidental = accedintal;
    Note *note = [[Note alloc] initWithNotePlacement:[[_staff notePlacements] objectAtIndex:pos] withInstrument:instrument];
    [_noteHolders  addObject: note];
    [self addSubview:note];
    if(!_volumeSlider){
        _volumeSlider = [[UISlider alloc] init];
        [_volumeSlider removeConstraints:_volumeSlider.constraints];
        [_volumeSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
        _volumeSlider.transform=CGAffineTransformRotate(_volumeSlider.transform,270.0/180*M_PI);
        int sliderWidth = 30;
        _volumeSlider.frame = CGRectMake(self.frame.size.width/2 -sliderWidth/2 +1 ,  _lineView.frame.size.height -1, sliderWidth, volumeMeterHeight);
         [_volumeSlider  setThumbImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
        [_volumeSlider setValue:0.75f];
        [self addSubview:_volumeSlider];
    }
    [_volumeSlider setHidden:NO];
        
}

@end
