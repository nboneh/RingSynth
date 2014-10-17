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
-(id)initWithEnv:(DetailViewController *)env{
    self = [super init];
    if(self){
        int height = env.bottomBar.frame.origin.y - (env.instrumentController.frame.origin.y + env.instrumentController.frame.size.height);
        Staff *staff = [[Staff alloc] initWithFrame:CGRectMake(0,[NotesHolder TITLE_VIEW_HEIGHT], 0, height -[NotesHolder VOLUME_METER_HEIGHT] -[NotesHolder TITLE_VIEW_HEIGHT])];
        mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width ,height)];
        container = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,0 ,height)];
        [container addSubview:staff];
        mainScroll.scrollEnabled = YES;
        mainScroll.userInteractionEnabled = YES;
        mainScroll.clipsToBounds = NO;
        container.clipsToBounds = NO;
        mainScroll.maximumZoomScale = 6.5f;
        NSInteger size = [[Assets getInstruments] count];
        NSMutableArray * preLayers = [[NSMutableArray alloc] init];
        for(int i = 0; i < 1; i++){
            Layout *layer = [[Layout alloc] initWithStaff:staff env:env];
            if(i == 0){
               mainScroll.contentSize = CGSizeMake(layer.frame.size.width +staff.trebleView.frame.size.width ,height);
                 self.frame = CGRectMake(0, env.instrumentController.frame.origin.y  + env.instrumentController.frame.size.height , staff.trebleView.frame.size.width + layer.frame.size.width,height );
                CGRect contFrame = container.frame;
                contFrame.size.width = staff.trebleView.frame.size.width + layer.frame.size.width;
                container.frame = contFrame;
                [staff increaseWidthOfLines: (staff.trebleView.frame.size.width + layer.frame.size.width)];
            }
            [preLayers addObject:layer];
            [container addSubview:layer];
        }
        layers = [[NSArray alloc] initWithArray:preLayers];
        [mainScroll addSubview:container];
        [mainScroll setDelegate:self];
        //Two Finger scroll
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(recognizePan:)];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        [mainScroll addGestureRecognizer:panGestureRecognizer];
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

@end
