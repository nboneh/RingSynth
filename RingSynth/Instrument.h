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

@property BOOL purchased;
@property (readonly)NoteDescription *baseNote;
@property (readonly)NSString *name;
@property (readonly)NSString *imageName;
@property(readonly)NSString *wavFilePath;
@property(readonly) UIImage *image;
@property(readonly) UIColor *color;
@property NSDictionary *notes;

-(id)initWithName:(NSString *)name color: (UIColor *)color;
-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave;
-(id)initWithName:(NSString *)name color: (UIColor *)color  andBaseOctave:(int)octave andPurchased:(BOOL)purchased;
-(id)initWithName:(NSString *)name color:(UIColor *)color andBaseNote:(NoteDescription *)noteDesc
    andImageName:(NSString *)imageName andWavPath:(NSString *)wavFilePath;


-(void) playNote: (NoteDescription *)note withVolume:(float)volume;
-(void)play;
-(float) duration;
-(struct NoteData )getDataNoteDescription:(NoteDescription *)note andVolume:(float)volume;
-(void)playRandomNote;
@end
