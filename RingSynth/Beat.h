//
//  Beat.h
//  RingSeq
//
//  Created by Nir Boneh on 10/16/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesHolder.h"
#import "ObjectAL.h"

typedef enum {
    triplets = 2,
    sixteenths = 3,
    numOfSubdivisions = 4
} Subdivision;
@protocol BeatDelegate
@optional
-(void)changeSubDivision:(Subdivision)subdivision;
@end
@interface Beat : UIView{
    int currentPlayingNoteHolder;
    NSTimer *playTimer;
    ALChannelSource *channel;
    NotesHolder *prevNoteHolder;
}

@property int num;
@property Staff *staff;
@property Subdivision currentSubdivision;
@property int widthPerNoteHolder;
@property (readonly)NSMutableArray *noteHolders;
@property NotesHolder *initialNotesHolder;
@property(nonatomic,assign)id delegate;

-(id) initWithStaff:(Staff *)staff  andFrame:(CGRect)frame andNum:(int)num andChannel:(ALChannelSource *)channel;

-(void)changeSubDivision:(Subdivision)subdivision;
-(BOOL)anyNotesInsubdivision;

-(BOOL)anyNotes;
-(void)playWithTempo:(int)bpm;
-(void)stop;
-(NotesHolder *)findNoteHolderAtX:(int)x;

-(NSDictionary*)createSaveFile;
-(void)loadSaveFile:(NSDictionary *)saveFile;

@end