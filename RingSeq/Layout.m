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
            Measure* measure =[[Measure alloc]initWithStaff:staff env:env x:delX withNum:i];
            [preMeasures addObject:measure];
            if(i == 0)
                widthPerMeasure =measure.frame.size.width;
                
            delX += widthPerMeasure;
            [self addSubview:measure];
        }
        measures = [[NSArray alloc] initWithArray:preMeasures];

        self.frame = CGRectMake(staff.trebleView.frame.size.width, staff.frame.origin.y -20,  widthPerMeasure * NUM_OF_MEASURES, staff.frame.size.height);
    }
    return self;
}

-(void) play{
    
}

@end
