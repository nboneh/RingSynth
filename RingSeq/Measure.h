//
//  Measure.h
//  RingSeq
//
//  Created by Nir Boneh on 10/16/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesHolder.h"

typedef enum {
    quaters = 0,
    eighths =1,
    triplets = 2,
    sixteenths = 3,
    numOfSubdivisions = 4
} Subdivision;
@protocol MeasureDelegate
@optional
-(void)changeSubDivision:(Subdivision)subdivision;
@end
@interface Measure : UIView{
    int currentPlayingNoteHolder;
    NSTimer *playTimer;
}

@property int num;
@property Staff *staff;
@property Subdivision currentSubdivision;
@property int widthPerNoteHolder;
@property NSMutableArray *noteHolders;
@property NotesHolder *initialNotesHolder;
@property(nonatomic,assign)id delegate;

-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andNum:(int)num;

-(void)changeSubDivision:(Subdivision)subdivision;
-(BOOL)anyNotesInsubdivision;

-(BOOL)anyNotes;
-(void)playWithTempo:(int)bpm;
-(void)stop;
-(NotesHolder *)findNoteHolderAtX:(int)x;

@end
