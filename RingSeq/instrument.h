//
//  instrument.h
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NoteDescription.h"
#import "ObjectAL.h"

@interface Instrument : NSObject
struct NoteData
{
    short int * noteData;
    int length;
};

@property (readonly)NSString *name;
@property(readonly) UIImage *image;
@property(readonly) UIColor *color;
@property NSDictionary *notes;
@property int baseOctave;

-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave;


-(void) playNote: (NoteDescription *)note withVolume:(float)volume andChannel:(ALChannelSource *)channel;
-(void)play;
-(float) duration;
-(struct NoteData )getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume;
-(void)playRandomNote;
@end
