//
//  InstrumentPurchaseView.m
//  RingSynth
//
//  Created by Nir Boneh on 11/4/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "InstrumentPurchaseView.h"


@implementation InstrumentPurchaseView
-(id)initWitInstrument:(Instrument *) instrument_ andX:(int)x{
    self = [super initWithImage:instrument_.image];
    if(self){
        instrument = instrument_;
        CGRect frame = self.frame;
        frame.origin.x = x;
        self.frame = frame;
        origFrame = self.frame;
        self.tintColor = instrument.color;
        [self setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
        
    }
    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self stopAnimation];
    [instrument play];
    stopAnimationTimer =[NSTimer scheduledTimerWithTimeInterval:instrument.duration
                                                target:self
                                              selector:@selector(stopAnimation)
                                              userInfo:nil
                                               repeats:NO];

    UIView *view = recognizer.view;
    [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction animations:^{
        CGRect frame = view.frame;
        frame.origin.y -= 3;
        view.frame = frame;
        
         frame = view.frame;
        frame.origin.y += 6;
        view.frame = frame;
    }completion:nil];
}
-(void)stopAnimation{
    [self.layer removeAllAnimations];
    [stopAnimationTimer invalidate];
    stopAnimationTimer = nil;
    self.frame = origFrame;
}

@end
