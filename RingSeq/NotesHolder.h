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
#import "Note.h"



@interface NotesHolder: UIView

@property UISlider *volumeSlider;
@property NSMutableArray *notes;
@property Staff *staff;
@property UIView *lineView;
@property UILabel *titleView;
@property int titleViewHeight;
@property int volumeMeterHeight;
-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andTitle:(NSString *)title;
-(void)placeNoteAtY:(int)y;
-(void)play;
-(BOOL)anyNotesInNoteHolder;
@end
