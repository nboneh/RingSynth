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
@interface Measure : UIView



@property DetailViewController * env;
@property Staff *staff;
@property Subdivision currentSubdivision;
@property  int spaceBetweenNoteHolders;
@property NSMutableArray *noteHolders;
@property NotesHolder *initialNotesHolder;
@property(nonatomic,assign)id delegate;

-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env x:(int)x withNum:(int)num;

-(void)changeSubDivision:(Subdivision)subdivision;
-(BOOL)anyNotesInsubdivision;

@end
