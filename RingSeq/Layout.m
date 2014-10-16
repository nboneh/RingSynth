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
-(Measure *)findMeasureIfExistsAtX:(int)x;
@end
@implementation Layout

static const int numOfMeasures = 50* 4;
-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env{
    self = [super init];
    if(self){
        widthPerMeasure=  staff.frame.size.width/13;
        self.frame = CGRectMake(staff.trebleView.frame.size.width, 0,  widthPerMeasure * numOfMeasures, staff.frame.size.height);
        NSMutableArray *preMeasures = [[NSMutableArray alloc] init];
        int delX =0;
        for(int i = 0; i < numOfMeasures; i++){
            NSString *title;
            switch( i%4){
                case 0:
                    title = [@(i/4 + 1) stringValue];
                    break;
                case 1:
                    title = @"e";
                    break;
                case 2:
                    title = @"&";
                    break;
                case 3:
                    title = @"a";
                    break;
                
            }
            Measure* measure =[[Measure alloc] initWithStaff:staff env:env x: delX andTitle:title];
            [preMeasures addObject:measure];
            delX += widthPerMeasure;
            [self addSubview:measure];
        }
        measures = [[NSArray alloc] initWithArray:preMeasures];
        
    }
    return self;
}

-(void) play{
    
}

@end
