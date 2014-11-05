//
//  PurchaseView.m
//  RingSynth
//
//  Created by Nir Boneh on 11/4/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "PurchaseView.h"

@implementation PurchaseView
-(id)initWithFrame:(CGRect)frame andPackInfo:(NSDictionary *)packInfo{
    self = [super initWithFrame:frame];
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                   selector: @selector(stopSample)
                       name: @"backgroundMusicStopped"
                     object: nil];

        int nameWidth = self.frame.size.width/6;
        int instDistance = frame.size.width/8;
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, nameWidth, self.frame.size.height)];
        labelName.text = [NSString stringWithFormat:@"%@:" ,[packInfo objectForKey:@"name"]];
        [self addSubview:labelName];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Increasing size of font if on ipad
            [labelName setFont:[UIFont systemFontOfSize:25]];
            
        } else{
             [labelName setFont:[UIFont systemFontOfSize:13]];
        }
        
        NSArray * instruments = [packInfo objectForKey:@"instruments"];
        for(int i = 0; i < instruments.count; i++){
            InstrumentPurchaseView* instrView = [[InstrumentPurchaseView alloc] initWitInstrument:[instruments objectAtIndex:i] andX:i*instDistance + nameWidth+ 10];
            CGRect instrFrame = instrView.frame;
            instrFrame.origin.y = self.frame.size.height/2 - instrFrame.size.height/2;
            instrView.frame = instrFrame;
            [self addSubview:instrView];
        }
        int xOfSample = (int)instruments.count * instDistance + nameWidth ;
      playSampleButton =   [UIButton buttonWithType:UIButtonTypeRoundedRect];playSampleButton.frame= CGRectMake(xOfSample, 0, nameWidth, self.frame.size.height);
        playSampleButton.titleLabel.textColor = self.tintColor;
       [playSampleButton setTitle:@"Play Sample!" forState:UIControlStateNormal];
        [playSampleButton addTarget:self
                   action:@selector(playSample:)
         forControlEvents:UIControlEventTouchUpInside];
      if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Increasing size of font if on ipad
            [playSampleButton.titleLabel  setFont:[UIFont systemFontOfSize:25]];
            
        } else{
            [playSampleButton.titleLabel  setFont:[UIFont systemFontOfSize:13]];
        }
        sampleName= [packInfo objectForKey:@"samplename"];
        [self addSubview:playSampleButton];
    }
    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        CGRect frame = view.frame;
        frame.origin.y -= 5;
        view.frame = frame;
    }completion:nil];
}

-(void)playSample:(UIButton *)button{
    if([button.titleLabel.text isEqualToString:@"Play Sample!"]){
          [[OALSimpleAudio sharedInstance] stopBg];
        stopSampleTimer =[NSTimer scheduledTimerWithTimeInterval:[self durationOfSample]
                                                             target:self
                                                           selector:@selector(stopSample)
                                                           userInfo:nil
                                                            repeats:NO];

        [button setTitle:@"Stop Sample!" forState:UIControlStateNormal];
        [[OALSimpleAudio sharedInstance] playBg:[NSString stringWithFormat:@"%@.m4a", sampleName]];
    } else{
        [[OALSimpleAudio sharedInstance] stopBg];
    }
    
}

-(void)stopSample{
    [playSampleButton setTitle:@"Play Sample!" forState:UIControlStateNormal];
    [stopSampleTimer  invalidate];
    stopSampleTimer = nil;
}

-(float) durationOfSample{
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:sampleName ofType:@"m4a"];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:musicPaths]  options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return  audioDurationSeconds;
}


@end
