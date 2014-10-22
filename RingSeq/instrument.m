//
//  instrument.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Instrument.h"

@implementation Instrument
@synthesize name = _name;
@synthesize image = _image;
-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave{
    self = [super init];
    if(self){
        _name = name;
        _color = color;
        _baseOctave = octave;
    }
    return self;
}

-(UIImage *)image{
    if(_image == nil) {
       _image = [[UIImage imageNamed:self.name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return _image;
}

-(void) playNote: (NoteDescription *)note withVolume:(float)volume andChannel:(ALChannelSource *)channel{
    ALChannelSource *mainChannel = [[OALSimpleAudio sharedInstance] channel];
   [OALSimpleAudio sharedInstance].channel = channel;
    int noteNum = 0;
    switch(note.character){
        case 'c':
            noteNum =0;
            break;
        case 'd':
            noteNum =2;
            break;
        case 'e':
            noteNum = 4;
            break;
        case 'f':
            noteNum =5;
            break;
        case 'g':
            noteNum =7;
            break;
        case 'a':
            noteNum = 9;
            break;
        case 'b':
            noteNum = 11;
            break;
    }
    if(note.accidental == sharp)
        noteNum++;
    else if(note.accidental == flat)
        noteNum--;
    float   pitch = pow(2,((note.octave-_baseOctave)+ (noteNum/12.0f)));
      [channel setVolume:volume];
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", self.name] volume:volume pitch:pitch pan:0.0f loop:NO];
    if(volume == 0.0f)
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    

    
    [OALSimpleAudio sharedInstance].channel = mainChannel;

    
}

-(void)play{
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", self.name]];
}
@end
