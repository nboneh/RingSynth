//
//  InstrumentControl.m
//  RingSeq
//
//  Created by Nir Boneh on 10/17/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "SlidingSegment.h"

@implementation SlidingSegment

-(id)initWithFrame:(CGRect)frame{
    self =[super  initWithFrame:frame];
    if(self){
        UIPanGestureRecognizer *panInstruments =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(panInstruments:)];
        [self addGestureRecognizer:panInstruments];
    }
    return self;
}

- (void)panInstruments:(UIPanGestureRecognizer *)gesture {
    static CGPoint originalCenter;
    if(self.frame.size.width > [[UIScreen mainScreen] bounds].size.width){
        if (gesture.state == UIGestureRecognizerStateBegan)
        {
            originalCenter = gesture.view.center;
            [self pauseLayer:gesture.view.layer];
        }
        else if (gesture.state == UIGestureRecognizerStateChanged)
        {
            CGPoint translate = [gesture translationInView:gesture.view.superview];
            if( (self.frame.origin.x + translate.x) <= 10 &&  (self.frame.origin.x + translate.x + self.frame.size.width) >= ([[UIScreen mainScreen] bounds].size.width - 10))
                gesture.view.center = CGPointMake(originalCenter.x + translate.x, originalCenter.y );
        }
        else if (gesture.state == UIGestureRecognizerStateEnded ||
                 gesture.state == UIGestureRecognizerStateFailed ||
                 gesture.state == UIGestureRecognizerStateCancelled)
        {
            [self resumeLayer:gesture.view.layer];
        }
    }
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

@end
