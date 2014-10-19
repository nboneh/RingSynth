//
//  Drums.m
//  RingSeq
//
//  Created by Nir Boneh on 10/18/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Drums.h"
#import "ObjectAL.h"
@implementation Drums

-(void) playNote: (NoteDescription *)note withVolume:(float)volume{
    if(!_sounds){
        NSDictionary *octave1 = @{@"e":@"Gong.wav",
                                  @"f":@"KickDrum1.wav",
                                  @"g": @"KickDrum2.wav",
                                  @"a" : @"KickDrum3.wav",
                                  @"b" :@"FloorTom.wav",
                                  @"c" :@"Tom.wav"};
        
        
        NSDictionary *octave2 =@{
                                  @"d":  @"Tom2.wav",
                                  @"e": @"RideCymbal1.wav",
                                  @"f": @"RideCymbal2.wav",
                                  @"g": @"RideCymbal3.wav",
                                  @"a" : @"Snare1.wav",
                                  @"b" :@"Snare2.wav",
                                  @"c" :@"Snare3.wav"

                                  };
        NSDictionary *octave3 = @{
                                   @"d":  @"Crash1.wav",
                                   @"e":  @"Crash2.wav",
                                   @"f": @"Crash3.wav",
                                   @"g": @"ClosedHiHat1.wav",
                                   @"a"     : @"ClosedHiHat2.wav",
                                   @"b" :@"ClosedHiHat3.wav",
                                   @"c" :@"OpenHiHat1.wav"
                                   };
        
        NSDictionary *octave4 = @{
                                  @"d": @"OpenHiHat2.wav",
                                   };
        _sounds = [[NSArray alloc] initWithObjects:octave1, octave2,octave3, octave4, nil];
        
    }
    float pitch = 1.0f;
    if(note.accidental == sharp)
        pitch += .1f;
    else if(note.accidental == flat)
        pitch -= .1f;
    NSString *drum =[(NSDictionary *)[_sounds objectAtIndex:(note.octave -3)] objectForKey:[NSString stringWithFormat:@"%c",(note.character) ]];
    [[OALSimpleAudio sharedInstance] playEffect:drum volume:volume pitch:pitch pan:0.0f loop:NO];
}


-(void)play{
    [[OALSimpleAudio sharedInstance] playEffect:@"Snare1.wav"];
    
}
@end
