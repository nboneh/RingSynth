//
//  InstrumentViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NoteDescription.h"
#import "AxonixAdView.h"

@interface ColorSelection : NSObject 
@property UIColor * color;
@property NSString * name;
-(id) initWithName:(NSString *)name andColor:(UIColor *)color;
@end

@interface InstrumentViewController : UIViewController<AVAudioRecorderDelegate,UIAlertViewDelegate, AVAudioPlayerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>{
    AVAudioRecorder *recorder;
    NSString *waveFilePath;
    AVAudioPlayer *player;
    UIColor * color;
    NSString * iconName;
    NoteDescription *baseNote;
    NSString * UUID;
    NSArray * colors;
    NSArray *icons;
    NSArray* chars;
    NSArray * accidentals;
    NSArray * octaves;
}

@property (weak, nonatomic) IBOutlet UIPickerView *notePicker;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIPickerView *iconPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *colorPicker;
@property AxonixAdView *bannerView;

-(IBAction) record;
-(IBAction) play;

@property ( nonatomic) NSDictionary* instrumentData;
@end
