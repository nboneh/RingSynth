//
//  Layout.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "Layout.h"

@interface Layout()
-(void)checkViews;
-(NotesHolder *)findMeasureIfExistsAtX:(int)x;
@end
@implementation Layout

static const int NUM_OF_MEASURES = 50;
-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env{
    self = [super init];
    if(self){
        NSMutableArray *preMeasures = [[NSMutableArray alloc] init];
        int delX =0;
        for(int i = 0; i < NUM_OF_MEASURES; i++){
            Measure* measure =[[Measure alloc]initWithStaff:staff env:env x:delX withNum:i+1];
            [preMeasures addObject:measure];
            if(i == 0){
                widthPerMeasure =measure.frame.size.width;
            }
            delX += widthPerMeasure;
            [self addSubview:measure];
            [measure setDelegate:self];
        
        }
        measures = [[NSArray alloc] initWithArray:preMeasures];

        self.frame = CGRectMake(staff.trebleView.frame.size.width, 0,  widthPerMeasure * NUM_OF_MEASURES,[(Measure *) [measures objectAtIndex:0] frame].size.height);
    }
    return self;
}

-(void) play{
    
}
-(void)changeSubDivision:(Subdivision)subdivision{
    NSInteger size = [measures count];
    for(int i = 0; i < size; i++){
        Measure* measure = [measures objectAtIndex:i];
        if(!measure.anyNotesInsubdivision)
            [measure changeSubDivision:subdivision];
    }
}

@end
