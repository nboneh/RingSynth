//
//  InstrumentControl.h
//  RingSeq
//
//  Created by Nir Boneh on 10/17/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlidingSegment : UISegmentedControl

-(void)pauseLayer:(CALayer*)layer;
-(void)resumeLayer:(CALayer*)layer;
@end
