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
-(id)initWithName:(NSString *)name color: (UIColor *)color{
    self = [super init];
    if(self){
        _name = name;
        _color = color;
        _baseNote = [[NoteDescription alloc] initWithOctave:4 andChar:'c'];
        _purchased = YES;
        _imageName = name;
    }
    return self;
    
}
-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave{
    self = [self initWithName:name color: color];
    if(self){
        _baseNote.octave = octave;
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

-(id)initWithName:(NSString *)name color:(UIColor *)color andBaseNote:(NoteDescription *)noteDesc
    andImageTitle:(NSString *)imageName andWavPath:(NSString *)wavFilePath{
    self = [self initWithName:name color:color ];
    if(self){
        _baseNote = noteDesc;
        _imageName = imageName;
        _wavFilePath = wavFilePath;
    }
    return self;
}

-(UIImage *)image{
    if(_image == nil) {
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            _image = [[UIImage imageNamed:[NSString stringWithFormat:@"%@-ipad",_imageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
        } else{
            _image = [[UIImage imageNamed:_imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        
    }
    return _image;
}

-(double)calcPitch:(NoteDescription *)noteDesc{
    int noteNum = 0;
    switch(noteDesc.character){
        case 'a':
            noteNum =0;
            break;
        case 'b':
            noteNum =2;
            break;
        case 'c':
            noteNum = 3;
            break;
        case 'd':
            noteNum =5;
            break;
        case 'e':
            noteNum =7;
            break;
        case 'f':
            noteNum = 8;
            break;
        case 'g':
            noteNum = 10;
            break;
    }
    
    switch(_baseNote.character){
        case 'a':
            noteNum+=0;
            break;
        case 'b':
            noteNum -= 2;
            break;
        case 'c':
            noteNum -= 3;
            break;
        case 'd':
            noteNum -=5;
            break;
        case 'e':
            noteNum -= 7;
            break;
        case 'f':
            noteNum -= 8;
            break;
        case 'g':
            noteNum -= 10;
            break;
            
    }
    if(noteDesc.accidental == sharp)
        noteNum++;
    else if(noteDesc.accidental == flat)
        noteNum--;
    
    if(_baseNote.accidental == sharp)
        noteNum--;
    else if(_baseNote.accidental == flat)
        noteNum++;
    
    return  pow(2,((noteDesc.octave-  _baseNote.octave)+ (noteNum/12.0f)));
    
}
-(void) playNote: (NoteDescription *)note withVolume:(float)volume{
    NSString*path;
    if(_wavFilePath)
        path = _wavFilePath;
    else
        path =[NSString stringWithFormat:@"%@.wav", self.name];
    [[OALSimpleAudio sharedInstance] playEffect:path volume:volume pitch:[self calcPitch:note] pan:0.0f loop:NO];
    
}

-(void)play{
    NSString*path;
    if(_wavFilePath)
        path = _wavFilePath;
    else
        path =[NSString stringWithFormat:@"%@.wav", self.name];
    [[OALSimpleAudio sharedInstance] playEffect:path];
}

-(float) duration{
    NSString* musicPaths;
    if(_wavFilePath)
        musicPaths = _wavFilePath;
    else
        musicPaths =[[NSBundle mainBundle] pathForResource:self.name ofType:@"wav"];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:musicPaths]  options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return  audioDurationSeconds;
}
-(struct NoteData  )getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume{
    NSString* musicPaths;
    if(_wavFilePath)
        musicPaths = _wavFilePath;
    else
        musicPaths =[[NSBundle mainBundle] pathForResource:self.name ofType:@"wav"];

    NSData * data = [[NSData alloc] initWithContentsOfFile:musicPaths];
    //Get rid of header file 44 bytes
    NSUInteger length = [data length] -44;
    short int*cdata = (  short int*)malloc(length);
    [data getBytes:(  short int*)cdata range:NSMakeRange(44,length)];
    for(int i = 0; i < (length /2); i++){
        cdata[i] = cdata[i] *volume;
    }
    
    float delta = 1.0f/[self calcPitch:note];
    //Extra space cause of algorithm
    int newLength = (length* delta)  -4;
    short int*outdata = (short int *) malloc(newLength);
    smb_pitch_shift(cdata, outdata,length/2, newLength/2,delta);
    free(cdata);
    struct NoteData noteData;
    noteData.length = newLength/2;
    noteData.noteData = outdata;
    return noteData;
}

-(void)playRandomNote{
    NoteDescription* note = [[NoteDescription alloc] initWithOctave: (arc4random_uniform(4) + _baseNote.octave -1) andChar:(arc4random_uniform(7) +'a')];
    note.accidental = arc4random_uniform(numOfAccedintals);
    [self playNote:note withVolume:1.0f];
}
@end
