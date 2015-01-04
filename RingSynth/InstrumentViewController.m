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
        
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self load];
    waveFilePath = [Util getPath:[NSString stringWithFormat:@"%@.wav", _name]];
    
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
               [[ColorSelection alloc] initWithName:@"Pink" andColor:[UIColor magentaColor]],
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
    for(Instrument * inst in [Assets INSTRUMENTS]){
        if(inst.purchased)
            [preIcons addObject:inst.name];
    }
    icons = [[NSArray alloc] initWithArray:preIcons];
    

    if([icons containsObject:iconName])
        [_iconPicker selectRow:[icons indexOfObject:iconName] inComponent:0 animated:NO];
    
    chars =@[@"a", @"b", @"c", @"d", @"e", @"f", @"g"];
    accidentals = @[@"♮",@"♯",@"♭"];
    
    
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
    [audioSession setActive:NO error:nil];
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
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignActive];
}

-(void) save{
    //Saving information and overwriting the current instrument in user instruments with this one
    NSMutableDictionary * instrumentInfo = [[NSMutableDictionary alloc] init];
    [instrumentInfo setValue:color forKey:@"color"];
    [instrumentInfo setValue: iconName forKey:@"imageName"];
    [instrumentInfo setValue:baseNote forKey:@"baseNote"];
    [instrumentInfo setValue:UUID forKey:@"uuid"];
    
    [NSKeyedArchiver archiveRootObject:instrumentInfo toFile:[Util getInstrumentPath:self.name]];
}

-(void) load{
    NSDictionary *instrumentInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[Util getInstrumentPath:self.name]];
    
    if(instrumentInfo == nil){
        //Generate a unique identifier, because user can rename the instrument therefore, the name of the instrument can't be used as its identifier
        
        UUID =  [[NSUUID UUID] UUIDString];
        
        
        //Loading defaults
        color = [UIColor redColor];
        iconName = @"Note";
        baseNote = [[NoteDescription alloc] initWithOctave:5 andChar:'c'] ;
        
    } else {
        color = [instrumentInfo objectForKey:@"color"];
        UUID = [instrumentInfo objectForKey:@"uuid"];
        iconName = [instrumentInfo objectForKey:@"imageName"];
        baseNote = [instrumentInfo objectForKey: @"baseNote"];
    }
    
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
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _colorPicker)
        return colors.count;
    else if(pickerView == _iconPicker)
        return icons.count;
    return 0;
}



- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if(pickerView == _colorPicker){
        UILabel *label = nil;
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            label.font = [UIFont systemFontOfSize:34];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 88)];
        } else {
            label.font = [UIFont systemFontOfSize:18];
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
        }
        
        ColorSelection * colorSelection = [colors objectAtIndex:row];
        label.textColor = colorSelection.color;
        label.text = colorSelection.name;
        return label;
    } else if (pickerView == _iconPicker){

        NSString * imageName = [icons objectAtIndex:row];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            imageName = [NSString stringWithFormat:@"%@-ipad",imageName];
        }
        UIImageView * imageView= [[UIImageView alloc] initWithImage: [[UIImage imageNamed:imageName]
                        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        imageView.tintColor = color;
        
        return imageView;
        
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == _colorPicker){
        ColorSelection * colorSelection = [colors objectAtIndex:row];
        color = colorSelection.color;
        [_iconPicker reloadAllComponents];
    }
    else if(pickerView == _iconPicker){
        iconName = [icons objectAtIndex:row];
    }
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
}


@end
