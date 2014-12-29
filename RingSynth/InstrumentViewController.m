//
//  InstrumentViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "InstrumentViewController.h"
#import "Util.h"

@interface InstrumentViewController ()
-(void)startRecording;
-(void)stopRecording;
@end

@implementation InstrumentViewController

#pragma mark - Managing the detail item

- (void)setName:(id)newDetailItem {
    if (_name != newDetailItem) {
        _name = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.name) {
        self.navigationItem.title = _name;
        waveFilePath = [Util getPath:[NSString stringWithFormat:@"%@.wav", _name]];
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if(![self recordingExists])
        [self.playButton setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter]  addObserver: self
               selector: @selector(resignActive)
                   name: @"applicationWillResignActive"
                 object: nil];
}


-(IBAction) record{
    if([_recordButton.titleLabel.text isEqualToString:@"Record"]){
            [self stopPlaying];
        if([self recordingExists]){
            UIAlertView * recordAlert = [[UIAlertView alloc] initWithTitle:@"Recoding already exists!" message:@"Do you want to overwrite it" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
            [recordAlert show];
        } else
            [self startRecording];
    }
    else if([_recordButton.titleLabel.text isEqualToString:@"Stop"]){
        [self stopRecording];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        [self startRecording];
    }
}

-(void)startRecording{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if(audioSession.recordPermission ==  AVAudioSessionRecordPermissionDenied ){
        UIAlertView * recordAlert = [[UIAlertView alloc] initWithTitle:@"Microphone settings disabled" message:@"Please allow app to use microphone in the settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [recordAlert show];

        return;
    }
    
    [_recordButton setTitle:@"Stop" forState:UIControlStateNormal];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryRecord error:&err];

    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    recorder = [[ AVAudioRecorder alloc] initWithURL: [NSURL fileURLWithPath:waveFilePath]  settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }



    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    
    [recorder prepareToRecord];
    [self.playButton setEnabled:NO];
    if(audioSession.recordPermission == AVAudioSessionRecordPermissionUndetermined){
        //If undecided don't record just prompt
        [audioSession setActive:NO error:nil];
        //Delete the file
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:waveFilePath error:nil];
        return;
    }

    
    [recorder recordForDuration:(NSTimeInterval) 5];
    
}


-(void) stopRecording{
    [recorder stop];
    
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
      [audioSession setCategory :AVAudioSessionCategoryPlayback error:nil];
    
    if([self recordingExists])
        [_playButton setEnabled:YES];
}

-(IBAction)play{
    if([_playButton.titleLabel.text isEqualToString:@"Play"]){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:waveFilePath]  error:nil];
        [player setDelegate:self];
        [player play];
        [_playButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else if([_playButton.titleLabel.text isEqualToString:@"Stop"]){
        [self stopPlaying];
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stopPlaying];
}

-(void) stopPlaying{
    [player stop];
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
}

-(BOOL) recordingExists{
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:waveFilePath];
    
}

-(void)resignActive{
    [recorder stop];
    [self stopPlaying];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignActive];
    
}

@end
