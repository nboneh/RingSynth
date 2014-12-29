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
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(stopSample)
                                                     name: @"stopPurchasePlayer"
                                                   object: nil];
        
        instrument = instrument_;
        CGRect frame = self.frame;
        frame.origin.x = x;
        self.frame = frame;
        origFrame = frame;
        self.tintColor = instrument.color;
        [self setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
    }
    return self;
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopSample];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"stopPurchasePlayer"
                                                        object: nil
                                                      userInfo: nil];
      player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:instrument.name ofType:@"wav"]]  error:nil];
    player.delegate = self;
    [player play];

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
-(void)stopSample{
    [player stop];
    [self.layer removeAllAnimations];
    self.frame = origFrame;
}



@end
