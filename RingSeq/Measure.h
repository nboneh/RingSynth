//
//  NoteHolder.h
//  RingSeq
//
//  Created by Nir Boneh on 10/12/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "NoteDescription.h"
#import "Staff.h"


@interface Note : UIView

@property NoteDescription *noteDescription;
@property Instrument *instrument;
-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument andAccedintal:(Accidental)accidental;

-(void) play;
@end

@interface Measure : UIView{
    int volumeMeterHeight;
}
@property Instrument * instrument;
@property  Accidental accedintal;
@property UISlider *volumeSlider;
@property NSMutableArray *noteHolders;
@property Staff *staff;
@property UIView *lineView;
-(id) initWithStaff:(Staff *)staff andX:(int)x andVolumeMeterHeight:(int)volumeHeight;
-(void)turnOnNoteAtPos:(int)pos;
-(void)deleteNoteAtPos:(int)pos;
-(void)play;
@end
