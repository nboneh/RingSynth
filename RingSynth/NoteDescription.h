//
//  NoteDescription.h
//  RingSeq
//
//  Created by Nir Boneh on 10/13/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteDescription : NSObject

typedef enum {
    natural = 0,
    sharp = 1,
    flat = 2,
    numOfAccedintals= 3
} Accidental;

@property int octave;
@property char character;
@property Accidental accidental;

-(id) initWithOctave:(int)octave andChar:(char)character;
-(id) initWithNoteDescription:(NoteDescription *) desc andAccedintal:(Accidental)accedintal;
-(void) inc;
-(void) dec;
@end
