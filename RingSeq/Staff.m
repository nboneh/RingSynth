//
//  Staff.m
//  RingSeq
//
//  Created by Nir Boneh on 10/13/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Staff.h"

@implementation  NotePlacement
@synthesize y = _y;
@synthesize noteDescs = _noteDescs;

-(id) initWithY:(int) y andNote:(NoteDescription *) noteDesc{
    self = [super init];
    if(self){
        self.y =y;
        NSMutableArray *preNoteDescs = [[NSMutableArray alloc] init];
        for(int i = 0; i < numOfAccedintals; i++){
            [preNoteDescs addObject:[[NoteDescription alloc] initWithNoteDescription:noteDesc andAccedintal:i]];
        }
        self.noteDescs = [[NSArray alloc] initWithArray:preNoteDescs];
        
    }
    return self;
}

@end

@implementation Staff
@synthesize notePlacements = _notePlacements;
@synthesize spacePerNote = _spacePerNote;
@synthesize trebleView = _trebleView;
static int const NOTES_BELOW_STAFF= 7;
static int const NOTES_ABOVE_STAFF =5;
static int const NOTES_IN_STAFF = 9;

-(id)initWithFrame:(CGRect )frame{
    self = [super initWithFrame:frame];
    if(self){

        int totalNotes = NOTES_BELOW_STAFF + NOTES_ABOVE_STAFF +NOTES_IN_STAFF;
         _spacePerNote = self.frame.size.height/totalNotes;

        NoteDescription*note = [[NoteDescription alloc] initWithOctave:5 andChar:'f'];
        for(int i = 0; i< NOTES_ABOVE_STAFF; i++){
            [note inc];
        }
        
        NSMutableArray *preNotePlacements = [[NSMutableArray alloc] init];
        int y = 0;
        NSMutableArray *preLines = [[NSMutableArray alloc] init];
        BOOL placeLine = !(NOTES_ABOVE_STAFF % 2);
        for(int i = 0; i < totalNotes; i++){
            [preNotePlacements addObject: [[NotePlacement alloc] initWithY:y  andNote: note ]];
            
            if(placeLine){
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 1)];
                [lineView setBackgroundColor:[UIColor blackColor]];
                if( i < NOTES_ABOVE_STAFF || i > (NOTES_ABOVE_STAFF + NOTES_IN_STAFF)){
                    //Outside notes in staff draw dim line
                    [lineView setAlpha:0.1f];
                  lineView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashedhorz"]];
                    //[lineView setColor]
                } else {
                    [lineView setBackgroundColor:[UIColor blackColor]];
                }
                [self addSubview:lineView];
                [preLines addObject:lineView];
            }
            [note dec];
            y += _spacePerNote;
            placeLine = !placeLine;
        }
        _lines = [[NSArray alloc] initWithArray:preLines];
        _notePlacements = [[NSArray alloc] initWithArray:preNotePlacements];
        _trebleView=  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"treble"]];
        _trebleView.frame =CGRectMake(0, _spacePerNote * (NOTES_ABOVE_STAFF - 3), [UIScreen mainScreen].bounds.size.width/8,_spacePerNote * (NOTES_IN_STAFF +6));
        [self addSubview: _trebleView];

    }
    return self;
}
-(void) increaseWidthOfLines:(int)width{
    NSInteger size = [_lines count];
    for(int i = 0; i <size; i++){
        UIView *line = [_lines objectAtIndex:i];
        CGRect lineFrame = line.frame;
        lineFrame.size.width = width;
        line.frame = lineFrame;
    }
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

@end
