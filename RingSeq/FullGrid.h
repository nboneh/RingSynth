//
//  FullGrid.h
//  l
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Layout.h"
#import "Instrument.h"

@interface FullGrid : UIScrollView<UIScrollViewDelegate>{
    NSMutableArray *layers;
    UIView *container;
    UIActionSheet *newColors;
    UISegmentedControl* instrumentsController;
    Staff* staff;
}

-(void)replay;
-(void)handleRotation;
-(void)changeLayer:(int)index;
-(void)addLayer;
-(void)deleteLayerAt:(int)index;
-(void)playWithTempo:(int)bpm;
-(void)stop;

@end
