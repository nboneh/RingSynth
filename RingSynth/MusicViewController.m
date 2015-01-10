
//
//  MusicViewController.m
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "MusicViewController.h"
#import "Assets.h"
#import "Staff.h"
#import "Layout.h"
#import "Util.h"
#import <Social/Social.h>


@interface MusicViewController ()
-(void)fixSegements;
-(void)addInstrument:(Instrument *)instrument fromLoad:(BOOL)load;
@end

@implementation MusicViewController

@synthesize bottomBar = _bottomBar;
static const int MIN_TEMPO =11;
static const int MAX_TEMPO = 500;

static  NSString *SHOWED_HELP = @"showedHelp";

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
    //Put view infront of popup
    
    
    
    self.fullScreenAdViewController = [[AxonixFullScreenAdViewController alloc] init];
    self.fullScreenAdViewController.delegate = self;

    self.automaticallyAdjustsScrollViewInsets = NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(resignActive:)
                   name: @"applicationWillResignActive"
                 object: nil];
    
    [center addObserver: self
               selector: @selector(musicStopped:)
                   name: @"musicStopped"
                 object: nil];
    CURRENT_INSTRUMENT = nil;
    CURRENT_ACCIDENTAL = natural;
    LOOPING = NO;
    
    editViewController = [[EditorViewController alloc] initWithNibName:@"Editor" bundle:nil];
    editViewController.totalPossibleBeats = MAX_BEATS;
    editViewController.delegate = self;
        firstTimeLoadingSubviews= YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)resignActive:(NSNotification *)notification{
    
    
    
    //Stoping sound
    [_fullGrid stop];
    
    //Saving file
    [self save];
}

-(void)musicStopped:(NSNotification *)notification{
    [_playButton setImage:[UIImage imageNamed:@"play"]];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(firstTimeLoadingSubviews){
        if(_instrumentController != nil)
            [_instrumentController removeFromSuperview];
        if(_fullGrid != nil)
            [_fullGrid removeFromSuperview];
        
        [ instruments removeAllObjects];
        
        int width = [[UIScreen mainScreen] bounds].size.width/10 ;
        _instrumentController = [[SlidingSegment alloc] initWithFrame:CGRectMake(0,0,width,30)];
        
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
        
        [_instrumentController removeAllSegments];
        [_instrumentController insertSegmentWithTitle:@"All" atIndex:0 animated:NO];
        [_instrumentController insertSegmentWithTitle:@"+" atIndex:1 animated:NO];
        [_instrumentController setSelectedSegmentIndex:0];
        [self fixSegements];
        
        
        
        
        CGRect gridFrame = CGRectMake(0,  _instrumentController.frame.origin.y + _instrumentController.frame.size.height, self.view.frame.size.width, _bottomBar.frame.origin.y - (_instrumentController.frame.origin.y + _instrumentController.frame.size.height));
        _fullGrid = [[FullGrid alloc] initWithFrame:gridFrame];
        [_fullGrid setNumOfBeats:[_beatsTextField.text intValue]];
        [self.view addSubview:_fullGrid];
        [self.view bringSubviewToFront: _instrumentController];
        [self.view bringSubviewToFront: _bottomBar];
        [self load];
        
    }
    firstTimeLoadingSubviews = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Reloading user Instruments in case they were changed
    
    int j = 0;
    for(NSObject * object in  savedInstruments){
        if([object isKindOfClass:[NSString class]]){
            [_instrumentController setSelectedSegmentIndex:(j+1)];
            Instrument * instrument =  [Assets instForObject:object];
            [instruments removeObjectAtIndex:j];
            [instruments insertObject:instrument atIndex:j];
            [_instrumentController removeSegmentAtIndex:(j+1) animated:NO];
            [_instrumentController insertSegmentWithImage:instrument.image atIndex:(j+1) animated:NO];
            [[[_instrumentController subviews] objectAtIndex:(j+1)] setTintColor:instrument.color];

            [_fullGrid changeInstrumentTo:instrument forLayer:((int)(j))];
        }
        j++;
    }
    [_instrumentController setSelectedSegmentIndex:0];
    [_fullGrid changeLayer:-1];
}
-(void) viewWillDisappear:(BOOL)animated
{
    //View will disappear save music
    [_fullGrid stop];
    [self save];
    [super viewWillDisappear:animated];
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
     savedInstruments = [[NSMutableArray alloc] init];
    for(Instrument * instrument in instruments){
        [savedInstruments addObject:[Assets objectForInst:instrument]];
    }
    [preSaveFile setValue:[[NSArray alloc] initWithArray:savedInstruments] forKey:@"instruments"];
    [preSaveFile setValue:[_fullGrid createSaveFile] forKey:@"fullGrid"];
    NSDictionary *saveFile = [[NSDictionary alloc] initWithDictionary:preSaveFile];
    [NSKeyedArchiver archiveRootObject:saveFile toFile:[Util getRingtonePath:(id) _name]];
}

-(void)load{
    NSDictionary *saveFile =[NSKeyedUnarchiver unarchiveObjectWithFile: [Util getRingtonePath:(id) _name]];
    if(saveFile){
        _tempoField.text =[saveFile objectForKey:@"tempo"];
        _beatsTextField.text = [saveFile objectForKey:@"beats"];
        NSArray *loadInstruments= [saveFile objectForKey:@"instruments"];
        for(NSObject * object in loadInstruments){
            [self addInstrument:[Assets instForObject:object] fromLoad:YES];
        }
        [_instrumentController setSelectedSegmentIndex:0];
        [_fullGrid setNumOfBeats:[_beatsTextField.text intValue]];
        [_fullGrid loadSaveFile:[saveFile objectForKey:@"fullGrid"]];
        [self.view addSubview:_fullGrid];
    } else {
        BOOL showedHelp = [[NSUserDefaults standardUserDefaults] boolForKey:SHOWED_HELP];
        if(!showedHelp){
            helpAlert = [[UIAlertView alloc] initWithTitle:@"First time making ringtone?" message:@"It is highly recommended to view the help screen!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [helpAlert show];
        }
        
    }
}


- (void)doubleTap:(UITapGestureRecognizer *)recognizer{
    CGPoint translate = [recognizer locationInView:_instrumentController];
    int selectedIndex =((translate.x/_instrumentController.frame.size.width) * [_instrumentController numberOfSegments]);
    if(selectedIndex > 0 && selectedIndex < ([_instrumentController numberOfSegments]  -1)){
        
        [_instrumentController setSelectedSegmentIndex:selectedIndex];
        [self presentInstrumentSheet];
    }
    
}

- (void)quickTap:(UITapGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded ){
        CGPoint translate = [recognizer locationInView:_instrumentController];
        
        [_instrumentController setSelectedSegmentIndex:((translate.x/_instrumentController.frame.size.width) * [_instrumentController numberOfSegments])];
        [self changeInstruments];
    }
}


-(void)presentInstrumentSheet{
    if([[Assets USER_INSTRUMENTS_KEYS] count] > 0 ){
        typeOfInstrumentsSheet = [[UIActionSheet alloc]initWithTitle:@"Choose Instrument Set" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Regular Instruments", @"User Instruments", nil];
    }
    else{
        typeOfInstrumentsSheet = [[UIActionSheet alloc]initWithTitle:@"Choose Instrument Set" delegate: self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Regular Instruments", @"Modulate your Voice! Make Instruments!", nil];
        
    }
    
    int pos = (int)[_instrumentController selectedSegmentIndex] -1 ;
    
    if(pos  <([_instrumentController numberOfSegments] -2) ){
        Instrument * instrument = [instruments objectAtIndex:pos];
        typeOfInstrumentsSheet.destructiveButtonIndex = [typeOfInstrumentsSheet addButtonWithTitle:[NSString stringWithFormat:@"Delete %@ ",instrument.name]];
    }
    [typeOfInstrumentsSheet showInView:self.view];
    
    
}

-(void)presentRegularInstrumentSheet{
    changeRegularInstrumentSheet = [[UIActionSheet alloc] initWithTitle:@"New Regular Instrument" delegate: self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_fullGrid stop];
    int pos = (int)[_instrumentController selectedSegmentIndex] -1 ;
    if(pos  <([_instrumentController numberOfSegments] -2) ){
        Instrument * instrument = [instruments objectAtIndex:pos];
        changeRegularInstrumentSheet.title = [NSString stringWithFormat:@"Editing %@", instrument.name];
        changeRegularInstrumentSheet.destructiveButtonIndex = [changeRegularInstrumentSheet addButtonWithTitle:[NSString stringWithFormat:@"Delete %@ ",instrument.name]];
    }
    for (Instrument *inst in [Assets INSTRUMENTS]) {
        //Checking if instrument is purchased to add it to the list of instruments
        if(inst.purchased)
            [changeRegularInstrumentSheet addButtonWithTitle:inst.name ];
        else
            [changeRegularInstrumentSheet addButtonWithTitle:[NSString stringWithFormat:@"\u26A0%@", inst.name] ];
        
    }
    changeRegularInstrumentSheet.cancelButtonIndex = [changeRegularInstrumentSheet addButtonWithTitle:@"Cancel"];
    
    [changeRegularInstrumentSheet showInView:self.view];
}

-(void)presentUserInstrumentSheet{
    changeUserInstrumentSheet = [[UIActionSheet alloc] initWithTitle:@"New Custom Instrument" delegate: self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_fullGrid stop];
    int pos = (int)[_instrumentController selectedSegmentIndex] -1 ;
    if(pos  <([_instrumentController numberOfSegments] -2) ){
        Instrument * instrument = [instruments objectAtIndex:pos];
        changeUserInstrumentSheet.title = [NSString stringWithFormat:@"Editing %@", instrument.name];
        changeUserInstrumentSheet.destructiveButtonIndex = [changeUserInstrumentSheet addButtonWithTitle:[NSString stringWithFormat:@"Delete %@ ",instrument.name]];
    }
    for (NSString *key in [Assets USER_INSTRUMENTS_KEYS]) {
        Instrument * inst = [[Assets USER_INSTRUMENTS] objectForKey:key];
        [changeUserInstrumentSheet addButtonWithTitle: inst.name];
        
    }
    [changeUserInstrumentSheet  addButtonWithTitle:@"Make More!"];
    changeUserInstrumentSheet.cancelButtonIndex = [changeUserInstrumentSheet addButtonWithTitle:@"Cancel"];
    
    [changeUserInstrumentSheet showInView:self.view];
}

-(void)changeInstruments{
    int pos = (int)[_instrumentController selectedSegmentIndex] -1 ;
    if(pos == ([_instrumentController numberOfSegments] -2)){
        [self presentInstrumentSheet];
    }
    else{
        if(pos >=  0){
            CURRENT_INSTRUMENT = [instruments objectAtIndex:pos];
            if(![_fullGrid isPlaying])
                [CURRENT_INSTRUMENT play];
        }
        else {
            CURRENT_INSTRUMENT = nil;
        }
        prevSelect = pos+1;
        [_fullGrid changeLayer:(pos)];
        
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    
    //Called twice bug
    if(actionSheet.tag != 0)
        return;
    
    actionSheet.tag = -1;
    
    if(actionSheet == sharingSheet){
        if(buttonIndex == actionSheet.cancelButtonIndex)
            return;
        [self.fullScreenAdViewController dismissViewControllerAnimated:YES completion:NULL];
        NSData *content = [[NSData alloc] initWithContentsOfFile:[Util getPath:[NSString stringWithFormat:@"%@.m4r", self.name]]];
        NSString * message = [NSString stringWithFormat:@"%@ is a neat ringtone I made in the App RingSynth for iOS. \n\r Check it out at: https://itunes.apple.com/app/id938020959", self.name];
        NSString * fileName = [NSString stringWithFormat:@"%@.m4a", self.name];
        NSString * title =[NSString stringWithFormat:@"Check out my ringtone %@", self.name];
        
        if(buttonIndex == 0){

            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            [mc setSubject: title];
            [mc setMessageBody:message isHTML:NO];
            
            [mc addAttachmentData:content mimeType:@"audio/wav" fileName:fileName];
            mc.mailComposeDelegate = self;
            // Present mail view controller on screen
            
            [self presentViewController:mc animated:YES completion:NULL];
            return;
        }
        else if(buttonIndex == 1){
             MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
            [mc setBody:message];
            [mc addAttachmentData:content typeIdentifier:@"audio/wav" filename:fileName];
            mc.messageComposeDelegate = self;
             [self presentViewController:mc animated:YES completion:nil];
            return;
            
        }
    }
    if(buttonIndex ==actionSheet.cancelButtonIndex){
        [_instrumentController setSelectedSegmentIndex:prevSelect];
        [_fullGrid changeLayer:prevSelect -1];
        return;
    }
    
    else if(buttonIndex == actionSheet.destructiveButtonIndex){
        if(!deleteAlert){
            deleteAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        }
        Instrument* instrument = [instruments objectAtIndex:[_instrumentController selectedSegmentIndex]- 1];
        [deleteAlert setTitle:[NSString stringWithFormat:@"Delete %@",instrument.name ]];
        [deleteAlert show];
        return;
        
    }
    
    else if(actionSheet == typeOfInstrumentsSheet){
        if(buttonIndex == 0)
            [self presentRegularInstrumentSheet];
        else if(buttonIndex ==1){
            if([Assets USER_INSTRUMENTS_KEYS].count == 0){
                [self performSegueWithIdentifier: @"pushInstrumentsFromMusic" sender: self];
                
            }
            else
                [self presentUserInstrumentSheet];
        }
        return;
    }
    
    BOOL addInstrument = [_instrumentController selectedSegmentIndex] == ([_instrumentController numberOfSegments] -1);
    
    Instrument * instrument;
    long index = buttonIndex;
    if(!addInstrument)
        index--;
    
    if(actionSheet == changeRegularInstrumentSheet)
        instrument = [[Assets INSTRUMENTS] objectAtIndex: index];
    else if(actionSheet == changeUserInstrumentSheet){
        
        if(index == [Assets USER_INSTRUMENTS_KEYS].count){
            [self performSegueWithIdentifier: @"pushInstrumentsFromMusic" sender: self];
            return;
        }
        instrument = [[Assets USER_INSTRUMENTS] objectForKey:[[Assets USER_INSTRUMENTS_KEYS] objectAtIndex: index]];
    }
    
    if(!instrument.purchased ){
        inAppPurchaseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is in app purchase", instrument.name ] message:@"Would you like to check out the shop?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [inAppPurchaseAlert show];
        [_instrumentController setSelectedSegmentIndex:prevSelect];
        [_fullGrid changeLayer:prevSelect -1];
        return;
    }
    
    
    
    
    
    
    if(addInstrument){
        //Add new Instrumenet
        [self addInstrument:instrument fromLoad:NO];
        [_fullGrid addLayer];
        
        [_instrumentController setSelectedSegmentIndex:([_instrumentController numberOfSegments] -2)];
        prevSelect =((int)[_instrumentController numberOfSegments] - 1);
        [self changeInstruments];
    }
    else{
        //Replace current instrument
        NSInteger pos = [_instrumentController selectedSegmentIndex];
        [instruments removeObjectAtIndex:(pos -1)];
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
        [_fullGrid setNumOfBeats: [_beatsTextField.text intValue]];
    }
    else if(alertView == sucessAlert){
        sharingSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat: @"Share ringtone %@?", self.name] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email", @"Text", nil];
        [sharingSheet showInView:self.view];
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
            prevSelect = 0;
            
        }
    }
    else if(alertView == inAppPurchaseAlert){
        if(buttonIndex == 1){
            [self performSegueWithIdentifier: @"pushShopFromMusic" sender: self];
        }
    }
    
    else if(alertView == helpAlert){
        if(buttonIndex == 1){
            [self performSegueWithIdentifier: @"pushHelpFromMusic" sender: self];
        }
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults] ;
        [userDefaults setBool:YES forKey:SHOWED_HELP];
        [userDefaults synchronize];
    }
    
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
    if([Util showAds])
        [self.fullScreenAdViewController requestAndDisplayAdFromViewController:self.navigationController];
    self.navigationItem.hidesBackButton = YES;
    //Saving for saftey
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

-(IBAction)openEditor:(id)sender{
    [_fullGrid stop];
    if(instruments.count == 0){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Nothing to Edit!" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString * title;
    long index = [_instrumentController selectedSegmentIndex] -1;
    if(index < 0)
        title = @"Editing All Instruments";
    else{
        Instrument * instrument = [instruments objectAtIndex:index];
        title = [NSString stringWithFormat:@"Editing %@",instrument.name];
    }
    
    [editViewController displayPopup:title totalBeats:_beatsTextField.text.intValue startingValue:[_fullGrid currentBeatNumber]];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send Text!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)exitedWithStartBeat:(int) startBeat endBeat:(int)endBeat insertBeat:(int) insertBeat EditingMode:(EditingMode)editingMode{
    if(editingMode != eraset){
        int totalBeatsRequired = insertBeat + (endBeat - startBeat) ;
        int beatsCurrently = _beatsTextField.text.intValue;
        if(totalBeatsRequired > beatsCurrently){
            [_fullGrid setNumOfBeats:totalBeatsRequired];
            _beatsTextField.text = [NSString stringWithFormat:@"%d", totalBeatsRequired];
        }
    }
    
    switch(editingMode){
        case duplicatet:
            [_fullGrid duplicateBeat:startBeat to:endBeat insert:insertBeat];
            break;
        case movet:
            [_fullGrid moveBeat:startBeat to:endBeat insert:insertBeat];
            break;
        case eraset:
            [_fullGrid clearBeat:startBeat to:endBeat];
            break;
    }
    
}
@end

