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
#import "DetailViewController.h"


@interface Note : UIView

@property NoteDescription *noteDescription;
@property Instrument *instrument;
-(id) initWithNotePlacement: (NotePlacement *)placement withInstrument:(Instrument *)instrument andAccedintal:(Accidental)accidental;

-(void) play;
@end

@interface Measure : UIView{
    int volumeMeterHeight;
    Note *noteBeingMoved;
}
@property DetailViewController * env;
@property UISlider *volumeSlider;
@property NSMutableArray *noteHolders;
@property Staff *staff;
@property UIView *lineView;
-(id) initWithStaff:(Staff *)staff andEnv: (DetailViewController *) env andX:(int)x;
-(void)turnOnNoteAtY:(int)y;
-(Note *)deleteNoteIfExistsAtY:(int)y;
-(void)play;
@end
