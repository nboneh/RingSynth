
//
//  DetailViewController.m
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "DetailViewController.h"
#import "Assets.h"
#import "Staff.h"
#import "Layout.h"

@interface DetailViewController ()
-(void)fixSegements;
-(void)addInstrument:(Instrument *)instrument fromLoad:(BOOL)load;
@end

@implementation DetailViewController

@synthesize bottomBar = _bottomBar;
static const int MIN_TEMPO =11;
static const int MAX_TEMPO = 500;

static const int MIN_BEATS =4;
static const int MAX_BEATS = 99;

static Accidental CURRENT_ACCIDENTAL;
static Instrument *CURRENT_INSTRUMENT;
static BOOL LOOPING;
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return  [self checkTextField:textField];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    //[self createAndLoadInterstitial];
    //Put view infront of popup
    
    
    
    firstTimeLoadingSubView = YES;
    self.fullScreenAdViewController = [[AxonixFullScreenAdViewController alloc] init];
    self.fullScreenAdViewController.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(resignActive:)
                   name: @"applicationWillResignActive"
                 object: nil];
    
    [center addObserver: self
               selector: @selector(becameActive:)
                   name: @"becameActive"
                 object: nil];
    [center addObserver: self
               selector: @selector(musicStopped:)
                   name: @"musicStopped"
                 object: nil];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    firstTimeLoadingSubView = YES;
    CURRENT_INSTRUMENT = nil;
    CURRENT_ACCIDENTAL = natural;
    LOOPING = NO;
    
    int width = [[UIScreen mainScreen] bounds].size.width/10 ;
    _instrumentController = [[SlidingSegment alloc] initWithFrame:CGRectMake(0,0,width,30)];
    [_instrumentController insertSegmentWithTitle:@"All" atIndex:0 animated:NO];
    [_instrumentController insertSegmentWithTitle:@"+" atIndex:1 animated:NO];
    [_instrumentController setSelectedSegmentIndex:0];
    UITapGestureRecognizer *quicktap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(quickTap:)];
    [_instrumentController addGestureRecognizer:quicktap];
    
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_instrumentController addGestureRecognizer:doubleTap];
    [self.view addSubview:_instrumentController];
    [self fixSegements];
}

-(void) viewDidLayoutSubviews{
    if(firstTimeLoadingSubView){
        CGRect gridFrame = CGRectMake(0,  _instrumentController.frame.origin.y + _instrumentController.frame.size.height, self.view.frame.size.width, _bottomBar.frame.origin.y - (_instrumentController.frame.origin.y + _instrumentController.frame.size.height));
        _fullGrid = [[FullGrid alloc] initWithFrame:gridFrame];
        [_fullGrid setNumOfMeasures:[_beatsTextField.text intValue]];
        [self.view addSubview:_fullGrid];
        [self.view bringSubviewToFront: _instrumentController];
        [self.view bringSubviewToFront: _bottomBar];
        [self load];
    }
    firstTimeLoadingSubView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resignActive:(NSNotification *)notification{
    
    
    
    //Stoping sound
    [_fullGrid stop];
    [_fullGrid silence];
    [_playButton setImage:[UIImage imageNamed:@"play"]];
    
    //Saving file
    [self save];
}

-(void)musicStopped:(NSNotification *)notification{
    [_playButton setImage:[UIImage imageNamed:@"play"]];
}

-(void) viewWillDisappear:(BOOL)animated
{
    //View will disappear save music
    [_fullGrid stop];
    [_fullGrid silence];
    [self save];
    [super viewWillDisappear:animated];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Unsilence the grid
    [[OALSimpleAudio sharedInstance] setMuted:YES];
    [self changeInstruments];
    [[OALSimpleAudio sharedInstance] stopAllEffects];
    [[OALSimpleAudio sharedInstance] setMuted:NO];

}

-(void)becameActive:(NSNotification *)notification{
    //Unsilence the grid
    
    [_fullGrid changeLayer:(int)(_instrumentController.selectedSegmentIndex -1)];
    
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    if(alertView.alertViewStyle ==UIAlertViewStylePlainTextInput){
        return [self checkTextField:[alertView  textFieldAtIndex:0]];
    }
    return YES;
}

-(BOOL)checkTextField:(UITextField *) textField{
    
    NSString *text = [textField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    int newValue = [text intValue];
    if([tempoAlert textFieldAtIndex:0] == textField)
        return newValue <= MAX_TEMPO && newValue >= MIN_TEMPO;
    else if([beatAlert textFieldAtIndex:0] == textField)
        return newValue <= MAX_BEATS && newValue >= MIN_BEATS;
    return YES;
    
    
}


-(void) save{
    NSMutableDictionary *preSaveFile = [[NSMutableDictionary alloc] init];
    [preSaveFile setValue:_tempoField.text  forKey:@"tempo"];
    [preSaveFile setValue: _beatsTextField.text forKey:@"beats"];
    NSMutableArray *saveInstruments = [[NSMutableArray alloc] init];
    for(Instrument * instrument in instruments){
        [saveInstruments addObject:[NSNumber numberWithInt:(int)[[Assets INSTRUMENTS] indexOfObject:instrument]]];
    }
    [preSaveFile setValue:[[NSArray alloc] initWithArray:saveInstruments] forKey:@"instruments"];
    [preSaveFile setValue:[_fullGrid createSaveFile] forKey:@"fullGrid"];
    NSDictionary *saveFile = [[NSDictionary alloc] initWithDictionary:preSaveFile];
    [NSKeyedArchiver archiveRootObject:saveFile toFile:[self getPath:(id) _name]];
}
-(void)load{
    NSDictionary *saveFile =[NSKeyedUnarchiver unarchiveObjectWithFile:[self getPath:(id) _name]];
    if(saveFile){
        _tempoField.text =[saveFile objectForKey:@"tempo"];
        _beatsTextField.text = [saveFile objectForKey:@"beats"];
        NSArray *loadInstruments= [saveFile objectForKey:@"instruments"];
        for(NSNumber * num in loadInstruments){
            Instrument* instrument =[[Assets INSTRUMENTS] objectAtIndex:[num intValue]];
            [self addInstrument:instrument fromLoad:YES];
        }
        [_instrumentController setSelectedSegmentIndex:0];
        [_fullGrid setNumOfMeasures:[_beatsTextField.text intValue]];
        [_fullGrid loadSaveFile:[saveFile objectForKey:@"fullGrid"]];
        [self.view addSubview:_fullGrid];
    }
}


- (void)doubleTap:(UITapGestureRecognizer *)recognizer{
    CGPoint translate = [recognizer locationInView:_instrumentController];
    int selectedIndex =((translate.x/_instrumentController.frame.size.width) * [_instrumentController numberOfSegments]);
    if(selectedIndex > 0 && selectedIndex < ([_instrumentController numberOfSegments]  -1)){
        
        [_instrumentController setSelectedSegmentIndex:selectedIndex];
        UIActionSheet *instrumentSheet = [self getInstrumentSheetWithInstrument:(Instrument *)[instruments objectAtIndex:(selectedIndex -1)] ];
        [instrumentSheet showInView:self.view];
    }
    
}

- (void)quickTap:(UITapGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded ){
        CGPoint translate = [recognizer locationInView:_instrumentController];
        
        [_instrumentController setSelectedSegmentIndex:((translate.x/_instrumentController.frame.size.width) * [_instrumentController numberOfSegments])];
        [self changeInstruments];
    }
}


-(UIActionSheet *)getInstrumentSheetWithInstrument:(Instrument *)instrument{
    UIActionSheet * instrumentSheet = [[UIActionSheet alloc] initWithTitle:@"New instrument" delegate: self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_fullGrid stop];
    if(instrument){
        instrumentSheet.title = [NSString stringWithFormat:@"Editing %@", instrument.name];
        instrumentSheet.destructiveButtonIndex = [instrumentSheet addButtonWithTitle:[NSString stringWithFormat:@"Delete %@ ",instrument.name]];
    }
    for (Instrument *inst in [Assets INSTRUMENTS]) {
        //Checking if instrument is purchased to add it to the list of instruments
        if(inst.purchased)
            [instrumentSheet addButtonWithTitle:inst.name ];
        else
            [instrumentSheet addButtonWithTitle:[NSString stringWithFormat:@"\u26A0%@", inst.name] ];
        
    }
    instrumentSheet.cancelButtonIndex = [instrumentSheet addButtonWithTitle:@"Cancel"];
    return instrumentSheet;
}

-(void)changeInstruments{
    int pos = (int)[_instrumentController selectedSegmentIndex] -1 ;
    if(pos == ([_instrumentController numberOfSegments] -2)){
        [[self getInstrumentSheetWithInstrument:nil ]  showInView:self.view];
    }
    else{
        [_fullGrid changeLayer:(pos)];
        if(pos >=  0){
            CURRENT_INSTRUMENT = [instruments objectAtIndex:pos];
            if(![_fullGrid isPlaying])
                [CURRENT_INSTRUMENT play];
        }
        else {
            CURRENT_INSTRUMENT = nil;
        }
        prevSelect = pos+1;
        
    }
    
}
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    


    if(buttonIndex ==popup.cancelButtonIndex){
        [_instrumentController setSelectedSegmentIndex:prevSelect];
        [_fullGrid changeLayer:prevSelect -1];
        return;
    }
    
    if([_instrumentController selectedSegmentIndex] == ([_instrumentController numberOfSegments] -1)){
        //Add new Instrumenet
        
        Instrument * instrument = [[Assets INSTRUMENTS] objectAtIndex: buttonIndex];
        if(!instrument.purchased ){
            inAppPurchaseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is in app purchase", instrument.name ] message:@"Would you like to check out the shop?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [inAppPurchaseAlert show];
            [_instrumentController setSelectedSegmentIndex:prevSelect];
            [_fullGrid changeLayer:prevSelect -1];
            return;
        }
        [self addInstrument:instrument fromLoad:NO];
        [_fullGrid addLayer];
        
        [_instrumentController setSelectedSegmentIndex:([_instrumentController numberOfSegments] -2)];
        prevSelect =((int)[_instrumentController numberOfSegments] - 1);
        [self changeInstruments];
    }
    else{
        //Replace or delete current instrument
        if(buttonIndex == popup.destructiveButtonIndex){
            if(!deleteAlert){
                deleteAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            }
            Instrument* instrument = [instruments objectAtIndex:[_instrumentController selectedSegmentIndex]- 1];
            [deleteAlert setTitle:[NSString stringWithFormat:@"Delete %@",instrument.name ]];
            [deleteAlert show];
            
        } else {
            Instrument * instrument = [[Assets INSTRUMENTS] objectAtIndex: (buttonIndex- 1)];
            if(!instrument.purchased ){
                inAppPurchaseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is in app purchase", instrument.name ] message:@"Would you like to check out the shop?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                [inAppPurchaseAlert show];
                [_instrumentController setSelectedSegmentIndex:prevSelect];
                [_fullGrid changeLayer:prevSelect -1];
                return;
            }

            NSInteger pos = [_instrumentController selectedSegmentIndex];
            [instruments removeObjectAtIndex:([_instrumentController selectedSegmentIndex] -1)];
            [instruments insertObject:instrument atIndex:(pos-1)];
            [_instrumentController removeSegmentAtIndex:[_instrumentController selectedSegmentIndex] animated:YES];
            [_instrumentController insertSegmentWithImage:instrument.image atIndex:pos animated:YES];
            [[[_instrumentController subviews] objectAtIndex:(([_instrumentController numberOfSegments]) -pos -1)] setTintColor:instrument.color];
            [_instrumentController setSelectedSegmentIndex:pos];
            [_fullGrid changeInstrumentTo:instrument forLayer:((int)(pos- 1))];
            CURRENT_INSTRUMENT = instrument;
            [instrument play];
        }
    }
}

-(void)addInstrument:(Instrument *)instrument fromLoad:(BOOL)load{
    if(!instruments)
        instruments = [[NSMutableArray alloc] init];
    int pos =(int)[_instrumentController numberOfSegments] -1;
    CGRect frame  =_instrumentController.frame;
    int add = frame.size.width/[_instrumentController numberOfSegments];
    frame.size.width += add;
    _instrumentController.frame = frame;
    [_instrumentController insertSegmentWithImage:instrument.image atIndex:pos animated:YES];
    [_instrumentController setSelectedSegmentIndex:pos];
    if(load)
        [[[_instrumentController subviews] objectAtIndex:1] setTintColor:instrument.color];
    else
        [[[_instrumentController subviews] objectAtIndex:pos] setTintColor:instrument.color];
    
    [instruments addObject:instrument];
    [self fixSegements];
}

-(IBAction)changeAccedintal:(UISegmentedControl *)sender{
    CURRENT_ACCIDENTAL = (Accidental)[sender selectedSegmentIndex];
    
}


+(Instrument *)CURRENT_INSTRUMENT{
    return CURRENT_INSTRUMENT;
}


+(Accidental )CURRENT_ACCIDENTAL{
    return CURRENT_ACCIDENTAL;
}

-(IBAction)replay{
    [_fullGrid replay];
}
-(IBAction)changeTempo{
    [_fullGrid stop];
    tempoAlert = [[UIAlertView alloc] initWithTitle:@"Change Tempo" message:[NSString stringWithFormat:@"Min: %d bpm Max: %d bpm" ,MIN_TEMPO, MAX_TEMPO]     delegate:self cancelButtonTitle:nil otherButtonTitles:@"Change", nil];
    tempoAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [tempoAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [tempoAlert textFieldAtIndex:0].text = _tempoField.text;
    [tempoAlert textFieldAtIndex:0].delegate = self;
    [tempoAlert show];
    
}

-(IBAction)changeBeat{
    [_fullGrid stop];
    
    beatAlert = [[UIAlertView alloc] initWithTitle:@"Change Number of Beats" message:[NSString stringWithFormat:@"Min: %d beats Max: %d beats" ,MIN_BEATS, MAX_BEATS]     delegate:self cancelButtonTitle:nil otherButtonTitles:@"Change", nil];
    beatAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [beatAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [beatAlert textFieldAtIndex:0].text = _beatsTextField.text;
    [beatAlert textFieldAtIndex:0].delegate = self;
    [beatAlert show];
    
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView == tempoAlert)
        _tempoField.text =  [NSString stringWithFormat:@"%d", [[alertView textFieldAtIndex:0].text intValue]];
    else if(alertView == beatAlert){
        _beatsTextField.text = [NSString stringWithFormat:@"%d", [[alertView textFieldAtIndex:0].text intValue]];
        [_fullGrid setNumOfMeasures: [_beatsTextField.text intValue]];
    }
    else if(alertView == sucessAlert){
        if(!emailAlert)
            emailAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Would you like to email %@?", self.name] message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [emailAlert show];
        [_fullGrid stop];
    }
    else if(alertView == deleteAlert){
        if(buttonIndex == 1){
            int deleteIndex = (int)[_instrumentController selectedSegmentIndex];
            
            [_fullGrid deleteLayerAt:(int)(deleteIndex-1)];
            [instruments removeObjectAtIndex:(deleteIndex-1)];
            CGRect frame  =_instrumentController.frame;
            int remove = frame.size.width/[_instrumentController numberOfSegments];
            frame.size.width -= remove;
            _instrumentController.frame = frame;
            [_instrumentController removeSegmentAtIndex:deleteIndex animated:YES];
            
            [_fullGrid changeLayer:-1];
            [_instrumentController setSelectedSegmentIndex:0];
            CURRENT_INSTRUMENT = nil;
            
            [self fixSegements];
            
        }
    }
    else if(alertView == emailAlert){
        if(buttonIndex == 1){
            [self.fullScreenAdViewController dismissViewControllerAnimated:YES completion:NULL];
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            [mc setSubject: [NSString stringWithFormat:@"Check out my ringtone %@", self.name]];
            [mc setMessageBody:[NSString stringWithFormat:@"%@ is a neat ringtone I made in the App %@ for iOS", self.name, [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]] isHTML:NO];
            NSData *content = [[NSData alloc] initWithContentsOfFile:[self getPath:[NSString stringWithFormat:@"%@.m4r", self.name]]];
            [mc addAttachmentData:content mimeType:@"audio/wav" fileName:[NSString stringWithFormat:@"%@.m4a", self.name]];
            mc.mailComposeDelegate = self;
            // Present mail view controller on screen
            
            [self presentViewController:mc animated:YES completion:NULL];
            
        }
    }
    else if(alertView == inAppPurchaseAlert){
        if(buttonIndex == 1){
            [self performSegueWithIdentifier: @"pushShopFromDetail" sender: self];
        }
    }
    
}
- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}
-(void)fixSegements{
    _instrumentController.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - _instrumentController.frame.size.width/2, [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.toolbar.frame.size.height
                                             , _instrumentController.frame.size.width, _instrumentController.frame.size.height);
    _instrumentController.tintColor = [UIColor blackColor];
}

-(IBAction)play:(UIBarButtonItem*)sender{
    if(_fullGrid.isPlaying){
        [_fullGrid stop];
    }
    else{
        [sender setImage:[UIImage imageNamed:@"pause"]];
        [_fullGrid playWithTempo:[_tempoField.text intValue]];
    }
}

-(IBAction)loop:(UIBarButtonItem*)sender{
    LOOPING = !LOOPING;
    if(LOOPING)
        [sender setImage:[UIImage imageNamed:@"loop"]];
    else
        [sender setImage:[UIImage imageNamed:@"noloop"]];
    
}

-(IBAction)exportMusic:(UIBarButtonItem *) button{
    [self.fullScreenAdViewController requestAndDisplayAdFromViewController:self];
    self.navigationItem.hidesBackButton = YES;
    //Saving as Saftey measure
    [self save];
    
    UIBarButtonItem* _createButton =  self.navigationItem.rightBarButtonItem;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.color = self.view.tintColor ;
    UIBarButtonItem * loadView = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = loadView;
    [activityIndicator startAnimating];
    [_fullGrid encodeWithBpm:[_tempoField.text intValue] andName:self.name andCompletionBlock:^(BOOL success){
        [_fullGrid stop];
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.rightBarButtonItem = _createButton;
        if(success ){
            
            if(!sucessAlert){
                sucessAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Ringtone %@ was created", self.name] message:@"Export it to your device via iTunes under file sharing apps" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            }
            [sucessAlert show];
        } else{
            UIAlertView* failAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error creating ringtone %@", self.name] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [failAlert show];
        }
    }
     
     ];
}

+(BOOL)LOOPING{
    return LOOPING;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)fullScreenAdViewController:(AxonixFullScreenAdViewController*)fullScreenAdViewController didFailToLoadWithError:(NSError*)error {
    NSLog(@"Failed to load full screen ad");
}
- (void)fullScreenAdViewControllerDidFinishLoad:(AxonixFullScreenAdViewController*)fullScreenAdViewController {
    NSLog(@"Full screen ad was loaded");
    
}


// Called when about to show ad

- (void)fullScreenAdViewControllerWillPresentAd:(AxonixFullScreenAdViewController*)fullScreenAdViewController {
    NSLog(@"Full screen ad will be presented");
    
    [fullScreenAdViewController.view removeFromSuperview];
    [self.view addSubview:fullScreenAdViewController.view];
    fullScreenAdViewController.view.window.windowLevel = UIWindowLevelAlert+100;
    
    
}

// Called when the ad is closed / dismissed

- (void)fullScreenAdViewControllerDidDismissAd:(AxonixFullScreenAdViewController*)fullScreenAdViewController {
    NSLog(@"Full screen ad was dismissed");
    fullScreenAdViewController.view.window.windowLevel = UIWindowLevelAlert-100;
}

@end

