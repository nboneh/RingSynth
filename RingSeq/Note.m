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
        CGRect imageFrame = _instrView.frame;
        self.frame = CGRectMake(0, placement.y - imageFrame.size.height/2, imageFrame.size.width, imageFrame.size.height);
        [self addSubview:_instrView];
        CGRect myFrame = self.frame;
        int width = myFrame.size.width/2;
        _accidentalView= [[UILabel alloc] initWithFrame:CGRectMake(-width * .8f,width/2,width,width)];
        _accidentalView.textColor = instrument.color;
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
            _accidentalView.text = @"#";
            break;
        case flat:
            _accidentalView.text = @"b";
            break;
        case numOfAccedintals:
            break;
            
    }
    _noteDescription = [_notePlacement.noteDescs objectAtIndex:accidental];
}


-(BOOL)equals:(Note *)note{
    if( self.notePlacement == note.notePlacement && self.instrument == note.instrument)
        return YES;
    return NO;
}

-(void) playWithVolume:(float)volume{
    
}


@end
