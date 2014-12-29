//
//  InstrumentViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface InstrumentViewController : UIViewController<AVAudioRecorderDelegate,UIAlertViewDelegate, AVAudioPlayerDelegate>{
    AVAudioRecorder *recorder;
    NSString *waveFilePath;
    AVAudioPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

-(IBAction) record;
-(IBAction) play;

@property (strong, nonatomic) id name;
@end
