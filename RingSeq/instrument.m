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
@synthesize  purchased = _purchased;
-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave{
    self = [super init];
    if(self){
        _name = name;
        _color = color;
        _baseOctave = octave;
        _purchased = YES;
    }
    return self;
}

-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave andPurchased:(BOOL)purchased{
    self = [self initWithName:name color:color andBaseOctave:octave];
    if(self){
        self.purchased = purchased;
    }
    return self;
}

-(UIImage *)image{
    if(_image == nil) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            _image = [[UIImage imageNamed:[NSString stringWithFormat:@"%@-ipad",self.name]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        } else{
              _image = [[UIImage imageNamed:self.name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }

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

-(float) duration{
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:self.name ofType:@"wav"];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:musicPaths]  options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return  audioDurationSeconds;
}
-(struct NoteData  )getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume{
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:self.name ofType:@"wav"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:musicPaths];
    //Get rid of header file 44 bytes
    NSUInteger length = [data length] -44;
    short int*cdata = (  short int*)malloc(length);
    for(int i = 0; i < (length/2); i++){
        cdata[i] = 0;
    }
    [data getBytes:(  short int*)cdata range:NSMakeRange(44,length)];
    for(int i = 0; i < (length /2); i++){
        cdata[i] = cdata[i] *volume;
    }
    
    float delta = 1.0f/[self calcPitch:note];
    //Extra space cause of algorithm
    int newLength = (length* delta) -4;
    short int*outdata = (short int *) malloc(newLength);
    smb_pitch_shift(cdata, outdata,length/2, newLength/2,delta);
    free(cdata);
    struct NoteData noteData;
    noteData.length = newLength/2;
    noteData.noteData = outdata;
    return noteData;
}

-(void)playRandomNote{
    NoteDescription* note = [[NoteDescription alloc] initWithOctave: (arc4random_uniform(4) + _baseOctave -1) andChar:(arc4random_uniform(7) +'a')];
    note.accidental = arc4random_uniform(numOfAccedintals);
    [self playNote:note withVolume:1.0f andChannel:[OALSimpleAudio sharedInstance].channel];
}
@end
