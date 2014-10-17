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



@interface NotesHolder: UIView

@property DetailViewController * env;
@property UISlider *volumeSlider;
@property NSMutableArray *noteHolders;
@property Staff *staff;
@property UIView *lineView;
@property UILabel *titleView;
-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env x:(int)x andTitle:(NSString *)title;
-(void)placeNoteAtY:(int)y fromExistingNote:(Note*)note;
-(Note *)deleteNoteIfExistsAtY:(int)ys;
-(void)play;
+(int)VOLUME_METER_HEIGHT;
+(int)TITLE_VIEW_HEIGHT;
@end
