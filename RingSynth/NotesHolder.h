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
#import "ObjectAL.h"



@interface NotesHolder: UIView {
    ALChannelSource * channel;
    BOOL bold;
}

@property UISlider *volumeSlider;
@property(readonly) NSMutableArray *notes;
@property Staff *staff;
@property UIView *lineView;
@property UILabel *titleView;
@property int titleViewHeight;
@property int volumeMeterHeight;
-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andTitle:(NSString *)title  andChannel:(  ALChannelSource *)  channel;
-(void)placeNoteAtY:(int)y;
-(Note *)deleteNoteIfExistsAtY:(int)y;
-(void)play;
-(BOOL)anyNotesInNoteHolder;
-(NSDictionary*)createSaveFile;
-(void)loadSaveFile:(NSDictionary *)saveFile;
-(void)lightUp;
-(void)unLightUp;
@end
