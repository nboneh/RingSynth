
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
#import "lame.h"

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
static EditMode CURRENT_EDIT_MODE;
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
        _fullGrid =[NSKeyedUnarchiver unarchiveObjectWithFile:[self getPath:(id)_name]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    firstTimeLoadingSubView = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(enteredBackground:)
                   name: @"didEnterBackground"
                 object: nil];
    
    [center addObserver: self
               selector: @selector(willEnterForeground:)
                   name: @"willEnterForeground"
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
    CURRENT_EDIT_MODE = insert;
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
    
    UILongPressGestureRecognizer *longpress =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(longPress:)];
    [_instrumentController addGestureRecognizer:longpress];
    
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

-(void)enteredBackground:(NSNotification *)notification{
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


-(void)willEnterForeground:(NSNotification *)notification{
    //Unsilence the grid
    [_fullGrid changeLayer:(int)(_instrumentController.selectedSegmentIndex -1)];
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    if(alertView.alertViewStyle ==UIAlertViewStylePlainTextInput){
        NSString *text = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        int newValue = [text intValue];
        if(alertView == tempoAlert)
            return newValue <= MAX_TEMPO && newValue >= MIN_TEMPO;
        else if(alertView == beatAlert)
            return newValue <= MAX_BEATS && newValue >= MIN_BEATS;
    }
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


- (void)longPress:(UILongPressGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded ){
        [_fullGrid stop];
        CGPoint translate = [recognizer locationInView:_instrumentController];
        int selectedIndex =((translate.x/_instrumentController.frame.size.width) * [_instrumentController numberOfSegments]);
        if(selectedIndex > 0 && selectedIndex < ([_instrumentController numberOfSegments]  -1)){
            [_instrumentController setSelectedSegmentIndex:selectedIndex];
            NSString *instrumentName = ((Instrument *)[instruments objectAtIndex:(selectedIndex-1)]).name;
            NSMutableString*message = [[NSMutableString alloc] init];
            [message appendString:@"Delete "];
            [message appendString:instrumentName];
            [message appendString:@"?"];
            UIAlertView * deleteAlert = [[UIAlertView alloc] initWithTitle:message message:@""   delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            
            [deleteAlert show];
            
        }
    }
}

- (void)quickTap:(UITapGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded ){
        CGPoint translate = [recognizer locationInView:_instrumentController];
        
        [_instrumentController setSelectedSegmentIndex:((translate.x/_instrumentController.frame.size.width) * [_instrumentController numberOfSegments])];
        [self changeInstruments];
    }
}

-(void)changeInstruments{
    int pos = (int)[_instrumentController selectedSegmentIndex] -1 ;
    if(pos == ([_instrumentController numberOfSegments] -2)){
        [_fullGrid stop];
        UIActionSheet *newInstruments = [[UIActionSheet alloc] initWithTitle:@"New instrument" delegate: self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for (Instrument *inst in [Assets INSTRUMENTS]) {
            [newInstruments addButtonWithTitle:inst.name];
        }
        newInstruments.cancelButtonIndex = [newInstruments addButtonWithTitle:@"Cancel"];
        
        [newInstruments showInView:self.view];
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
    if(buttonIndex != popup.cancelButtonIndex){
        Instrument * instrument = [[Assets INSTRUMENTS] objectAtIndex: buttonIndex];
        [self addInstrument:instrument fromLoad:NO];
        [_instrumentController setSelectedSegmentIndex:([_instrumentController numberOfSegments] -2)];
        prevSelect =((int)[_instrumentController numberOfSegments] - 1);
        [_fullGrid addLayer];
        [self changeInstruments];
    }
    else{
        [_instrumentController setSelectedSegmentIndex:prevSelect];
        [_fullGrid changeLayer:prevSelect -1];
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

-(IBAction)changeEditMode:(UISegmentedControl *)sender{
    CURRENT_EDIT_MODE =(EditMode)[sender selectedSegmentIndex];
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
    [tempoAlert show];
    
}

-(IBAction)changeBeat{
    [_fullGrid stop];
    
    beatAlert = [[UIAlertView alloc] initWithTitle:@"Change Number of Beats" message:[NSString stringWithFormat:@"Min: %d beats Max: %d beats" ,MIN_BEATS, MAX_BEATS]     delegate:self cancelButtonTitle:nil otherButtonTitles:@"Change", nil];
    beatAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [beatAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [beatAlert textFieldAtIndex:0].text = _beatsTextField.text;
    [beatAlert show];
    
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.alertViewStyle ==UIAlertViewStylePlainTextInput){
        if(alertView == tempoAlert)
            _tempoField.text =  [alertView textFieldAtIndex:0].text;
        else if(alertView == beatAlert){
            _beatsTextField.text = [alertView textFieldAtIndex:0].text;
            [_fullGrid setNumOfMeasures: [_beatsTextField.text intValue]];
        }
    }
    else{
        if(buttonIndex == 1){
            int deleteIndex = (int)[_instrumentController selectedSegmentIndex];
            if(prevSelect == deleteIndex)
                prevSelect = 0;
            else if(deleteIndex <= prevSelect)
                prevSelect--;
            
            
            [_fullGrid deleteLayerAt:(int)(deleteIndex-1)];
            [instruments removeObjectAtIndex:(deleteIndex-1)];
            CGRect frame  =_instrumentController.frame;
            int remove = frame.size.width/[_instrumentController numberOfSegments];
            frame.size.width -= remove;
            _instrumentController.frame = frame;
            [_instrumentController removeSegmentAtIndex:deleteIndex animated:YES];
            
            [_fullGrid changeLayer:(prevSelect-1 )];
            [_instrumentController setSelectedSegmentIndex:(prevSelect)];
            if((prevSelect -1)>0)
                CURRENT_INSTRUMENT = [instruments objectAtIndex: prevSelect-1 ];
            
            [self fixSegements];
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

-(IBAction)exportMusic{
    @try {
        int read, write;
        lame_t lame = lame_init();
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
}

+(EditMode)CURRENT_EDIT_MODE{
    return CURRENT_EDIT_MODE;
}
+(BOOL)LOOPING{
    return LOOPING;
}

@end

