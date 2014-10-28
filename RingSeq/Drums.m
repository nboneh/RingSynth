//
//  Drums.m
//  RingSeq
//
//  Created by Nir Boneh on 10/18/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Drums.h"
#import "ObjectAL.h"
#import "PitchShift.h"
@implementation Drums

-(void) playNote: (NoteDescription *)note withVolume:(float)volume andChannel:(ALChannelSource *)channel{
    ALChannelSource *mainChannel = [[OALSimpleAudio sharedInstance] channel];
    [OALSimpleAudio sharedInstance].channel = channel;
    [self initWavs];
    float pitch = 1.0f;
    if(note.accidental == sharp)
        pitch += .1f;
    else if(note.accidental == flat)
        pitch -= .1f;
    if(volume == 0.0f)
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    NSString *drum =[(NSDictionary *)[_sounds objectAtIndex:(note.octave -3)] objectForKey:[NSString stringWithFormat:@"%c",(note.character) ]];
      [channel setVolume:volume];
    [[OALSimpleAudio sharedInstance] playEffect:drum volume:volume pitch:pitch pan:0.0f loop:NO];
    if(volume == 0.0f)
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    
    [OALSimpleAudio sharedInstance].channel = mainChannel;
    

}
-(void)initWavs{
    if(!_sounds){
        NSDictionary *octave1 = @{@"e":@"Gong.wav",
                                  @"f":@"KickDrum1.wav",
                                  @"g": @"KickDrum2.wav",
                                  @"a" : @"KickDrum3.wav",
                                  @"b" :@"FloorTom.wav"
                                  };
        
        
        NSDictionary *octave2 =@{
                                 @"c" :@"Tom.wav",
                                 @"d":  @"Tom2.wav",
                                 @"e": @"RideCymbal1.wav",
                                 @"f": @"RideCymbal2.wav",
                                 @"g": @"RideCymbal3.wav",
                                 @"a" : @"Snare1.wav",
                                 @"b" :@"Snare2.wav"
                                 
                                 
                                 };
        NSDictionary *octave3 = @{
                                  @"c" :@"Snare3.wav",
                                  @"d":  @"Crash1.wav",
                                  @"e":  @"Crash2.wav",
                                  @"f": @"Crash3.wav",
                                  @"g": @"ClosedHiHat1.wav",
                                  @"a"     : @"ClosedHiHat2.wav",
                                  @"b" :@"ClosedHiHat3.wav",
                                  @"c" :@"OpenHiHat1.wav"
                                  };
        
        NSDictionary *octave4 = @{
                                  @"c" :@"OpenHiHat1.wav",
                                  @"d": @"OpenHiHat2.wav"
                                  };
        _sounds = [[NSArray alloc] initWithObjects:octave1, octave2,octave3, octave4, nil];
        
    }

}

-(void)play{
    [[OALSimpleAudio sharedInstance] playEffect:@"Snare1.wav"];
    
}

-(NSData *)getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume{
 [self initWavs];
    NSString *drum =[(NSDictionary *)[_sounds objectAtIndex:(note.octave -3)] objectForKey:[NSString stringWithFormat:@"%c",(note.character) ]];
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:[drum substringWithRange:NSMakeRange(0,[drum rangeOfString:@".wav" ].location)] ofType:@"wav"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:musicPaths];
    NSUInteger length = [data length] -44;
    short int*cdata = (  short int*)malloc(length);
    for(int i = 0; i < (length/2); i++){
        cdata[i] = 0;
    }
    [data getBytes:(  short int*)cdata range:NSMakeRange(44,length)];
    float pitch = 1.0f;
    if(note.accidental == sharp)
        pitch += .1f;
    else if(note.accidental == flat)
        pitch -= .1f;

    float delta = 1/pitch;

    for(int i = 0; i < length/2; i++){
        cdata[i] = cdata[i] *volume;
    }
    [self initWavs];
    //Extra space cause of algorithm
     int newLength = (length * delta) -4;
    short int*outdata = (short int *) malloc(newLength);
    for(int i = 0; i < (newLength/2); i++){
        outdata[i] = 0;
    }
   smb_pitch_shift(cdata,outdata,length/2, newLength/2,delta);
    

    free(outdata);
    free(cdata);
    return data;
}


@end
