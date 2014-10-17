//
//  FullGrid.m
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "FullGrid.h"
#import "Assets.h"
#import "NotesHolder.h"
@implementation FullGrid
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
        int instrumentsControlWidth = frame.size.width*0.8f;
        int instrumentsControlHeight = frame.size.height * 0.2f;
        UISegmentedControl* instruments = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0,0, instrumentsControlWidth, instrumentsControlHeight)];
        [instruments setTintColor:[UIColor blackColor]];
        [instruments insertSegmentWithTitle:@"All" atIndex:0 animated:NO];
        [instruments insertSegmentWithTitle:@"+" atIndex:1 animated:NO];
        [self addSubview:instruments];
        
        [instruments addTarget:self
                             action:@selector(instrumentChange:)
                   forControlEvents:UIControlEventValueChanged];
        
        UISegmentedControl* accidentals = [[UISegmentedControl alloc] initWithFrame:CGRectMake(instrumentsControlWidth, 0, frame.size.width - instrumentsControlWidth, instrumentsControlHeight)];
         [self addSubview:accidentals];
        [accidentals insertSegmentWithTitle:@"♮" atIndex:0 animated:NO];
        [accidentals insertSegmentWithTitle:@"#" atIndex:1 animated:NO];
        [accidentals insertSegmentWithTitle:@"b" atIndex:2 animated:NO];
        
        [accidentals addTarget:self
                        action: @selector(accidentalChange:)
              forControlEvents:UIControlEventValueChanged];
        
        int volumeMeterSpace = frame.size.height/10;
        int titleSpace = frame.size.height/12;
        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,instrumentsControlHeight,frame.size.width,frame.size.height- instrumentsControlHeight )];
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, mainScroll.frame.size.height)];
        Staff *staff = [[Staff alloc] initWithFrame:CGRectMake(0,titleSpace, frame.size.width, mainScroll.frame.size.height -titleSpace - volumeMeterSpace)];
        [container addSubview:staff];
        mainScroll.scrollEnabled = YES;
        //mainScroll.userInteractionEnabled = YES;
        mainScroll.maximumZoomScale = 6.5f;
        mainScroll.minimumZoomScale = 0.5f;
        [mainScroll addSubview:container];
        [mainScroll setDelegate:self];
        [self addSubview:mainScroll];

    }
    return self;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return container;
}
- (void)recognizePan:(UIPanGestureRecognizer *)recognizer{
    
}

-(void)replay{
    CGRect frame = CGRectMake(0, 0, mainScroll.frame.size.width, mainScroll.frame.size.height);
    [mainScroll setZoomScale:1.0f animated:YES];
    [mainScroll scrollRectToVisible:frame animated:YES];
}

-(void)handleRotation{
      //mainScroll.contentSize = CGSizeMake(mainScroll.contentSize.height, mainScroll.contentSize.width);
    CGRect frame = mainScroll.frame;
    frame.size.width = mainScroll.frame.size.height;
       frame.size.height = frame.size.width;
    mainScroll.frame = frame;
}

- (void)instrumentChange:(UISegmentedControl *)sender{
    
}

- (void)accidentalChange:(UISegmentedControl *)sender{
    
}

@end
