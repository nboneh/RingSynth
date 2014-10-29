//
//  Note.m
//  RingSeq
//
//  Created by Nir Boneh on 10/14/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Note.h"
@implementation Note
@synthesize instrument = _instrument;
@synthesize accidental = _accidental;

-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument andAccedintal:(Accidental)accidental{
    self = [super init];
    if(self){
        _instrument = instrument;
        _notePlacement =placement;
        _noteDescription = [placement.noteDescs objectAtIndex:accidental];
        _instrView = [[UIImageView alloc] initWithImage:[instrument image]];
        [_instrView setTintColor:instrument.color];

        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Making image twice as large if on ipad and raising it up a tid bit
            CGRect frame = _instrView.frame;
            frame.size.width = frame.size.width *2;
            frame.size.height = frame.size.height *2;
            frame.origin.y -= 5;
            _instrView.frame = frame;

        }
         CGRect imageFrame = _instrView.frame;
        self.frame = CGRectMake(0, placement.y - imageFrame.size.height, imageFrame.size.width, imageFrame.size.height);
        [self addSubview:_instrView];
        CGRect myFrame = self.frame;
        int width = myFrame.size.width;
        _accidentalView= [[UILabel alloc] initWithFrame:CGRectMake(-width/2,width/8,width,width)];
        _accidentalView.textColor = instrument.color;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Increasing size of font if on ipad
            [_accidentalView setFont:[UIFont systemFontOfSize:40]];
            CGRect frame = _accidentalView.frame;
            frame.origin.y -= 8;
            _accidentalView.frame = frame;
        }
        [self addSubview:_accidentalView];
        [self setAccidental:_noteDescription.accidental];
        
    }
    return self;
}


-(void)setAccidental:(Accidental)accidental{
    _accidental =accidental;
    switch(accidental){
        case natural:
            _accidentalView.text = @"";
            break;
        case sharp:
            _accidentalView.text = @"♯";
            break;
        case flat:
            _accidentalView.text = @"♭";
            break;
        case numOfAccedintals:
            break;
            
    }
    _noteDescription = [_notePlacement.noteDescs objectAtIndex:accidental];
}

-(void)setInstrument:(Instrument *)instrument{
    _instrument = instrument;
      [_instrView setTintColor:instrument.color];
    [_instrView setImage:instrument.image];
    [_accidentalView setTextColor:instrument.color];
}
-(BOOL)equals:(Note *)note{
    if( self.notePlacement == note.notePlacement && self.instrument == note.instrument)
        return YES;
    return NO;
}

-(void) playWithVolume:(float)volume andChannel:(ALChannelSource *)channel{
    [self.instrument playNote:self.noteDescription withVolume:volume andChannel:channel];
}

@end
