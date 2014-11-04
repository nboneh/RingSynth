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
    if(volume == 0.0f)
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    NSString *drum =  [self getDrumWithNoteDescription:note];
    [[OALSimpleAudio sharedInstance] playEffect:[NSString stringWithFormat:@"%@.wav", drum] volume:volume pitch:1.0f pan:0.0f loop:NO];
    if(volume == 0.0f)
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    
    [OALSimpleAudio sharedInstance].channel = mainChannel;
    
    
}
-(id)getDrumWithNoteDescription:(NoteDescription *)note{
    if(!_sounds){
        NSDictionary *octave1 = @{@"e":@[@"Gong", @"Synth-Cowbell",@"DameSon"],
                                  @"f":@[@"Shaker", @"Kick-Snare", @"Zill"],
                                  @"g": @[@"Clap",@"Clap2", @"Snap"],
                                  @"a" : @[@"Low-Bongo",@"Kalimba",@"CrazyKalimba"],
                                  @"b" :@[@"Hi-Bongo",@"BikeBell",@"LowTimp"]
                                  };
        
        
        NSDictionary *octave2 =@{
                                 @"c" :@[@"KickDrum2", @"SlapNoise",@"Timpani"],
                                 @"d":  @[@"PedalHiHat",@"KickDrum3", @"Side-Stick"],
                                 @"e": @[@"BassDrum", @"HandDrum", @"KettleDrum1"],
                                 @"f": @[@"BassDrum2", @"DoumbekTek", @"Click"],
                                 @"g": @[@"FloorTom", @"OpenRimShot", @"Clacker"],
                                 @"a" : @[@"FloorTom2",@"Electro-Tom",@"Tambourine2"],
                                 @"b" :@[@"LowTom", @"Tambourine", @"Low-Synth-Tom"]
                                 
                                 
                                 };
        NSDictionary *octave3 = @{
                                  @"c" :@[@"Snare", @"Rimshot", @"BuzzSnare"],
                                  @"d":  @[@"RideCymbal1",@"MidTom1",@"Woodblock"],
                                  @"e":  @[@"MidTom2", @"Cowbell",@"HalfOpenHiHat"],
                                  @"f": @[@"RideCymbal2", @"HiTom",@"Hi-Synth-Tom"],
                                  @"g": @[@"ClosedHiHat",@"OpenHiHat", @"ClosedHiHat2"],
                                  @"a" : @[@"Crash1", @"Triangle", @"TriangleMute"],
                                  @"b" :@[@"Splash", @"Splash2", @"Crash2"]
                                  };
        
        NSDictionary *octave4 = @{
                                  @"c" :@[@"China",@"Sizzle",@"Crash3"],
                                  @"d": @[@"Klank",@"TurnDown",@"Klank2"]
                                  };
        _sounds = [[NSArray alloc] initWithObjects:octave1, octave2,octave3, octave4, nil];
        
    }
    return [[(NSDictionary *)[_sounds objectAtIndex:(note.octave -3)] objectForKey:[NSString stringWithFormat:@"%c",(note.character) ]] objectAtIndex:note.accidental];
    
}

-(void)play{
    [[OALSimpleAudio sharedInstance] playEffect:@"Snare.wav"];
    
}

-(struct NoteData  )getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume{
    NSString *drum =[self getDrumWithNoteDescription:note];
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:drum ofType:@"wav"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:musicPaths];
    NSUInteger length = [data length] -44;
    short int*cdata = (  short int*)malloc(length);
    for(int i = 0; i < length/2; i++){
        cdata[i] = 0;
    }
    [data getBytes:(  short int*)cdata range:NSMakeRange(44,length)];
    for(int i = 0; i < length/2; i++){
        cdata[i] = cdata[i] *volume;
    }
    data = [NSData dataWithBytes:(const void *)cdata length:(length)];
    struct NoteData noteData;
    noteData.length = (int)length/2;
    noteData.noteData = cdata;

    return noteData;
}
-(void)playRandomNote{
    NoteDescription* note;
    do{
        note = [[NoteDescription alloc] initWithOctave: (arc4random_uniform(4) + self.baseOctave -1) andChar:(arc4random_uniform(7) + 'a')];
        
    }while(![self getDrumWithNoteDescription:note]);
    
    note.accidental = arc4random_uniform(numOfAccedintals);
    
    [self playNote:note withVolume:1.0f andChannel:[OALSimpleAudio sharedInstance].channel];
}


@end
