//
//  NoteDescription.m
//  RingSeq
//
//  Created by Nir Boneh on 10/13/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "NoteDescription.h"

@implementation NoteDescription : NSData

@synthesize accidental = _accedintal;
@synthesize character = _character;
@synthesize octave = _octave;

-(id) initWithOctave:(int)octave andChar:(char)character{
    self = [super init];
    if(self){
        self.accidental = natural;
        self.character = character;
        self.octave = octave;
    }
    return self;
}

-(id) initWithNoteDescription:(NoteDescription *) desc andAccedintal:(Accidental)accedintal{
    self = [super init];
    if(self){
        self.accidental = accedintal;
        self.character = desc.character;
        self.octave = desc.octave;
    }
    return self;
}

-(void) inc{
    if(self.character == 'g'){
        self.octave++;
        self.character = 'a';
    }
    else
        self.character++;
    
}

-(void) dec{
    
    if(self.character == 'a'){
        self.octave--;
        self.character = 'g';
    }
    else
        self.character--;
}

@end
