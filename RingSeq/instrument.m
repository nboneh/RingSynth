//
//  instrument.m
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Instrument.h"
#import "PitchShift.h"

@interface Instrument()
-(double)calcPitch:(NoteDescription *)noteDesc;
@end
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

-(double)calcPitch:(NoteDescription *)noteDesc{
    int noteNum = 0;
    switch(noteDesc.character){
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
    if(noteDesc.accidental == sharp)
        noteNum++;
    else if(noteDesc.accidental == flat)
        noteNum--;
    return  pow(2,((noteDesc.octave-_baseOctave)+ (noteNum/12.0f)));
    
}
-(void) playNote: (NoteDescription *)note withVolume:(float)volume andChannel:(ALChannelSource *)channel{
    ALChannelSource *mainChannel = [[OALSimpleAudio sharedInstance] channel];
    [OALSimpleAudio sharedInstance].channel = channel;
    [channel setVolume:volume];
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", self.name] volume:volume pitch:[self calcPitch:note] pan:0.0f loop:NO];
    if(volume == 0.0f)
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    
    [OALSimpleAudio sharedInstance].channel = mainChannel;
    
}

-(void)play{
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", self.name]];
}

-(NSData *)getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume{
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:self.name ofType:@"wav"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:musicPaths];
    //Get rid of header file 44 bytes
    NSUInteger length = [data length] -44;
    short int*cdata = (  short int*)malloc(length);
    [data getBytes:(  short int*)cdata range:NSMakeRange(44,length)];
    for(int i = 0; i < length /2; i++){
        cdata[i] = cdata[i] *volume;
    }
    
    float delta = 1/[self calcPitch:note];
    int newLength = (length* delta);
    short int*outdata = (short int *) malloc(newLength);
    
    smb_pitch_shift(cdata, outdata,length/2, newLength/2,delta);
    
    data = [NSData dataWithBytes:(const void *)outdata length:(newLength)];
    free(cdata);
    free(outdata);
    return data;
}


@end
