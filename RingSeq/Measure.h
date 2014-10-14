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
#import "Note.h"



@interface Measure : UIView{
    int volumeMeterHeight;
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
