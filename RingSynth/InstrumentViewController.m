//
//  InstrumentViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "InstrumentViewController.h"
#import "Util.h"
#import "PitchShift.h"
#import "Assets.h"
#import "Instrument.h"

@implementation ColorSelection
@synthesize color = _color;
@synthesize name = _name;
-(id) initWithName:(NSString *)name andColor:(UIColor *)color{
    self = [super init];
    if(self){
        _name = name;
        _color = color;
    }
    return self;
}
@end

@interface InstrumentViewController ()
-(void)startRecording;
-(void)stopRecording;
@end

@implementation InstrumentViewController

#pragma mark - Managing the detail item

- (void)setInstrumentData:(NSDictionary*)newDetailItem {
    if (_instrumentData != newDetailItem) {
        _instrumentData = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.instrumentData) {
        self.navigationItem.title = [_instrumentData objectForKey:@"name"];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self load];
    
    if([Util showAds]){
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
            self.bannerView = [[AxonixAdViewiPad_728x90 alloc] init];
        else
            self.bannerView = [[AxonixAdViewiPhone_320x50 alloc] init];
        CGRect bannerFrame = self.bannerView.frame;
        bannerFrame.origin.y = self.view.frame.size.height - bannerFrame.size.height;
        bannerFrame.origin.x = self.view.frame.size.width/2 - bannerFrame.size.width/2;
        self.bannerView.frame = bannerFrame;
        
        [self.view addSubview:self.bannerView];
    }

    waveFilePath = [Util getPath:[NSString stringWithFormat:@"%@.wav", UUID]];
    
    if(![self recordingExists])
        [self.playButton setEnabled:NO];
    [[NSNotificationCenter defaultCenter]  addObserver: self
                                              selector: @selector(resignActive)
                                                  name: @"applicationWillResignActive"
                                                object: nil];
    
    colors = @[[[ColorSelection alloc] initWithName:@"Red" andColor:[UIColor redColor]],
               [[ColorSelection alloc] initWithName:@"Purple" andColor:[UIColor purpleColor]],
               [[ColorSelection alloc] initWithName:@"Blue" andColor:[UIColor blueColor]],
               [[ColorSelection alloc] initWithName:@"Green" andColor:[UIColor greenColor]],
               [[ColorSelection alloc] initWithName:@"Yellow" andColor:[UIColor yellowColor]],
               [[ColorSelection alloc] initWithName:@"Orange" andColor:[UIColor orangeColor]],
               [[ColorSelection alloc] initWithName:@"Pink" andColor:[UIColor colorWithRed:(255/255.0) green:(105/255.0) blue:(180/255.0) alpha:1.0]],
               [[ColorSelection alloc] initWithName:@"Light Blue" andColor:[UIColor cyanColor]],
               [[ColorSelection alloc] initWithName:@"Brown" andColor:[UIColor brownColor]],
               [[ColorSelection alloc] initWithName:@"Gray" andColor:[UIColor grayColor]],
               [[ColorSelection alloc] initWithName:@"Black" andColor:[UIColor blackColor]]
               ];
    for(int i = 0; i < colors.count; i++){
        ColorSelection * colorSelect = [colors objectAtIndex:i];
        if(color == colorSelect.color){
            [_colorPicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
    
    NSMutableArray * preIcons = [[NSMutableArray alloc] init];
    
    [preIcons addObject:@"Note"];
    [preIcons addObject:@"Micro"];
    [preIcons addObject:@"Micro2"];
    for(Instrument * inst in [Assets INSTRUMENTS]){
        if(inst.purchased)
            [preIcons addObject:inst.name];
    }
    icons = [[NSArray alloc] initWithArray:preIcons];
    
    
    if([icons containsObject:iconName])
        [_iconPicker selectRow:[icons indexOfObject:iconName] inComponent:0 animated:NO];
    else
        iconName = [icons objectAtIndex:[_iconPicker selectedRowInComponent:0]];
    
    chars =@[@" a", @" b", @" c", @" d", @" e", @" f", @" g"];
    accidentals = @[@"♮",@" ♯",@" ♭"];
    octaves = @[@"6",@"5",@"4",@"3"];
    
    char baseNoteChar = baseNote.character;
    for(int i = 0; i < chars.count; i++){
        if(baseNoteChar == [[chars objectAtIndex:i]   characterAtIndex:1]){
            [_notePicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
    
    [_notePicker selectRow:baseNote.accidental inComponent:1 animated:NO];
    int baseNoteOctave = baseNote.octave;
    for(int i = 0; i < chars.count; i++){
        if(baseNoteOctave == [[octaves objectAtIndex:i] intValue]){
            [_notePicker selectRow:i inComponent:2 animated:NO];
            break;
        }
    }
    

    
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([Util showAds])
        [self.bannerView resumeAdAutoRefresh];
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
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
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
    [recordSetting setValue:[NSNumber numberWithInt:(kAudioFormatLinearPCM | kLinearPCMFormatFlagIsPacked)] forKey:AVFormatIDKey];
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
    
    [recorder recordForDuration:(NSTimeInterval) 5];
    
}


-(void) stopRecording{
    [recorder stop];
    
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
    
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:nil];

    [self processWavFile];
    if([self recordingExists])
        [_playButton setEnabled:YES];
}

-(IBAction)play{
    
    // [[OALSimpleAudio sharedInstance] playEffect:waveFilePath];
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
    [self save];
    [self.bannerView pauseAdAutoRefresh];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignActive];
}

-(void) save{
    //Saving information and overwriting the current instrument in user instruments with this on
    [_instrumentData setValue:color forKey:@"color"];
    [_instrumentData setValue: iconName forKey:@"imageName"];
    [_instrumentData setValue:baseNote forKey:@"baseNote"];
}

-(void) load{
  
        color = [_instrumentData objectForKey:@"color"];
        UUID = [_instrumentData objectForKey:@"uuid"];
        iconName = [_instrumentData objectForKey:@"imageName"];
        baseNote = [_instrumentData objectForKey: @"baseNote"];
    
}

-(void)processWavFile{
    NSData * data = [[NSData alloc] initWithContentsOfFile:waveFilePath];
    //Get rid of useless data, 4096 bytes including headers and zeroes
    NSUInteger length = [data length] -4096 ;
    
    if(length <= 0){
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:waveFilePath error:nil];
        return;
    }
    
    //We will truncate the quite begginning for better quality notes
    short int*cdata = (  short int*)malloc(length);
    [data getBytes:(  short int*)cdata range:NSMakeRange(4096,length)];
    short int maxValue = 0;
    long sizeInShort = length/2;
    for(int i = 0; i < sizeInShort; i++){
        short int val =abs(cdata[i]) ;
        if(val > maxValue)
            maxValue = val;
    }
    
    short int cutOffValue = maxValue/10;
    long startIndex = 0;
    for(int i = 0; i < sizeInShort; i++){
        short int val =abs(cdata[i]) ;
        if(val >= cutOffValue){
            startIndex = i;
            break;
        }
    }
    
    //Go back just a little bit so sound does not start "too Immediate"
    startIndex -= 1000;
    if(startIndex < 0)
        startIndex = 0;
    long newLength = length - startIndex*2;
    int channels = 2;
    long totalNewLength = newLength + 44;
    long sampleRate = 44100;
    
    //Overwriting existing wavfile with truncated one
    Byte*newWaveFile = ( Byte*)malloc( totalNewLength);
    long byteRate = 16 * 11025.0 * channels/8;
    newWaveFile[0] = 'R';
    newWaveFile[1] = 'I';
    newWaveFile[2] = 'F';
    newWaveFile[3] = 'F';
    newWaveFile[4] = (Byte) (totalNewLength & 0xff);
    newWaveFile[5] = (Byte) ((totalNewLength >> 8) & 0xff);
    newWaveFile[6] = (Byte) ((totalNewLength >> 16) & 0xff);
    newWaveFile[7] = (Byte) ((totalNewLength >> 24) & 0xff);
    newWaveFile[8] = 'W';
    newWaveFile[9] = 'A';
    newWaveFile[10] = 'V';
    newWaveFile[11] = 'E';
    newWaveFile[12] = 'f';  // 'fmt ' chunk
    newWaveFile[13] = 'm';
    newWaveFile[14] = 't';
    newWaveFile[15] = ' ';
    newWaveFile[16] = 16;  // 4 bytes: size of 'fmt ' chunk
    newWaveFile[17] = 0;
    newWaveFile[18] = 0;
    newWaveFile[19] = 0;
    newWaveFile[20] = 1;  // format = 1
    newWaveFile[21] = 0;
    newWaveFile[22] = channels;
    newWaveFile[23] = 0;
    newWaveFile[24] = (Byte) (sampleRate & 0xff);
    newWaveFile[25] = (Byte) ((sampleRate >> 8) & 0xff);
    newWaveFile[26] = (Byte) ((sampleRate >> 16) & 0xff);
    newWaveFile[27] = (Byte) ((sampleRate >> 24) & 0xff);
    newWaveFile[28] = (Byte) (byteRate & 0xff);
    newWaveFile[29] = (Byte) ((byteRate >> 8) & 0xff);
    newWaveFile[30] = (Byte) ((byteRate >> 16) & 0xff);
    newWaveFile[31] = (Byte) ((byteRate >> 24) & 0xff);
    newWaveFile[32] = (Byte) (2 * 8 / 8);  // block align
    newWaveFile[33] = 0;
    newWaveFile[34] = 16;  // bits per sample
    newWaveFile[35] = 0;
    newWaveFile[36] = 'd';
    newWaveFile[37] = 'a';
    newWaveFile[38] = 't';
    newWaveFile[39] = 'a';
    newWaveFile[40] = (Byte) (newLength & 0xff);
    newWaveFile[41] = (Byte) ((newLength >> 8) & 0xff);
    newWaveFile[42] = (Byte) ((newLength >> 16) & 0xff);
    newWaveFile[43] = (Byte) ((newLength >> 24) & 0xff);
    
    long j = 22;
    
    short int*newWaveFileShorts = (short int*)&newWaveFile[j];
    for(long i = startIndex; i <  sizeInShort; i++){
        newWaveFileShorts[j] = cdata[i];
        j++;
    }
    free(cdata);
    
    NSData *newdata = [NSData dataWithBytes:(const void *)newWaveFile length:(totalNewLength)];
    [[NSFileManager defaultManager] createFileAtPath:waveFilePath
                                            contents:newdata
                                          attributes:nil];
    
    
    free(newWaveFile);
    
    
    [[OALSimpleAudio sharedInstance] unloadEffect:waveFilePath];
    
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView == _notePicker)
        return 3;
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _colorPicker)
        return colors.count;
    else if(pickerView == _iconPicker)
        return icons.count;
    else if(pickerView == _notePicker){
        switch(component){
            case 0:
                return chars.count;
            case 1:
                return accidentals.count;
            case 2:
                return octaves.count;
        }
    }
    return 0;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 44;
    else
        return 22;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if (pickerView == _iconPicker){
        
        NSString * imageName = [icons objectAtIndex:row];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
            imageName = [NSString stringWithFormat:@"%@-ipad", imageName];
        }
        UIImageView * imageView= [[UIImageView alloc] initWithImage: [[UIImage imageNamed:imageName]
                                                                      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = color;
        
        return imageView;
        
    }
    UILabel *label = nil;

    int width =pickerView.frame.size.width/pickerView.numberOfComponents;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        label.font = [UIFont systemFontOfSize:23];
        CGRect frame = label.frame;
        frame.size.height = frame.size.height*2;
        label.frame = frame;
    }
    else
        label.font = [UIFont systemFontOfSize:17];
    
    if(pickerView == _colorPicker){
        ColorSelection * colorSelection = [colors objectAtIndex:row];
        label.textColor = colorSelection.color;
        label.text = colorSelection.name;
        return label;
    }
    
    else if (pickerView == _notePicker){
        switch(component){
            case 0:
                label.text = [[chars objectAtIndex:row] uppercaseString];
                break;
            case 1:
                label.text = [accidentals objectAtIndex:row];
                break;
            case 2:
                label.text = [octaves objectAtIndex:row];
                break;
        }
        return label;
        
    }
    return nil;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    if(pickerView == _colorPicker){
        ColorSelection * colorSelection = [colors objectAtIndex:row];
        color = colorSelection.color;
        [_iconPicker reloadAllComponents];
    }
    else if(pickerView == _iconPicker){
        iconName = [icons objectAtIndex:row];
    }
    else if(pickerView == _notePicker){
        switch(component){
            case 0:
                baseNote.character = [[chars objectAtIndex:row] characterAtIndex:1];
                break;
            case 1:
                baseNote.accidental = (Accidental)row;
                break;
            case 2:
                baseNote.octave = [[octaves objectAtIndex:row] intValue];
                break;
                
        }
    }
}


@end
