//
//  instrument.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Instrument.h"
#import "ObjectAL.h"

@implementation Instrument
@synthesize name = _name;
@synthesize image = _image;
-(id)initWithName:(NSString *)name color: (UIColor *)color{
    self = [super init];
    if(self){
        _name = name;
        _color = color;
    }
    return self;
}

-(UIImage *)image{
    if(_image == nil) {
        _image = [[UIImage imageNamed:self.name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _image;
}

-(void) playNote: (NoteDescription *)note withVolume:(float)volume{
    float pitch = 0;
    switch(note.character){
        case 'a':
            pitch = .85f;
            break;
        case 'b':
            pitch = .95f;
            break;
        case 'c':
            pitch = 1.0f;
            break;
        case 'd':
             pitch = 1.1f;
            break;
        case 'e':
             pitch = 1.2f;
            break;
        case 'f':
             pitch = 1.25f;
            break;
        case 'g':
             pitch = 1.35f;
            break;
    }
    if(note.accidental == sharp)
        pitch += .05f;
    else if(note.accidental == flat)
        pitch -= .05f;
    pitch /= (note.octave/4);
    
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", self.name] volume:volume pitch:pitch pan:0.0f loop:NO];

    
}

-(void)play{
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", self.name]];
}
@end
