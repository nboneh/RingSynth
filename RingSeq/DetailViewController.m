
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
@end

@implementation DetailViewController

@synthesize bottomBar = _bottomBar;
static const int MIN_TEMPO =11;
static const int MAX_TEMPO = 500;
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
               selector: @selector(musicStoppedByApp:)
                   name: @"musicStoppedByApp"
                 object: nil];
    
    
    //NSArray* instruments = [Assets getInstruments];
    //NSInteger size = [instruments count];
    firstTimeLoadingSubView = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    CURRENT_ACCIDENTAL = natural;
    CURRENT_EDIT_MODE = insert;
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
    LOOPING = NO;
}
-(void) viewDidLayoutSubviews{
    
    if(!_fullGrid){
        CGRect gridFrame = CGRectMake(0,  _instrumentController.frame.origin.y + _instrumentController.frame.size.height, self.view.frame.size.width, _bottomBar.frame.origin.y - (_instrumentController.frame.origin.y + _instrumentController.frame.size.height));
        _fullGrid = [[FullGrid alloc] initWithFrame:gridFrame];
        [self.view addSubview:_fullGrid];
        [self.view bringSubviewToFront: _instrumentController];
        [self.view bringSubviewToFront: _bottomBar];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enteredBackground:(NSNotification *)notification{
    //Saving file
    [self save];
    //Stoping sound
    [_fullGrid stop];
    [_fullGrid silence];
    [_playButton setImage:[UIImage imageNamed:@"play"]];
    
}

-(void)musicStoppedByApp:(NSNotification *)notification{
    [_playButton setImage:[UIImage imageNamed:@"play"]];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    //View will disappear save music
    [self save];
    [_fullGrid silence];
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
        
        int newTempo = [text intValue];
        return newTempo <= MAX_TEMPO && newTempo >= MIN_TEMPO;
    }
    return YES;
}



-(void) save{
    //  [NSKeyedArchiver archiveRootObject:fullGrid toFile:[self getPath:(id) _name]];
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer{
    if(recognizer.state == UIGestureRecognizerStateEnded ){
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
        if(!instruments)
            instruments = [[NSMutableArray alloc] init];
        int pos =(int)[_instrumentController numberOfSegments] -1;
        CGRect frame  =_instrumentController.frame;
        int add = frame.size.width/[_instrumentController numberOfSegments];
        frame.size.width += add;
        _instrumentController.frame = frame;
        Instrument * instrument = [[Assets INSTRUMENTS] objectAtIndex: buttonIndex];
        [_instrumentController insertSegmentWithImage:instrument.image atIndex:pos animated:YES];
        [_instrumentController setSelectedSegmentIndex:pos];
        [[[_instrumentController subviews] objectAtIndex:pos] setTintColor:instrument.color];
        [_fullGrid addLayer];
        [instruments addObject:instrument];
        [_instrumentController setSelectedSegmentIndex:([_instrumentController numberOfSegments] -2)];
        prevSelect =((int)[_instrumentController numberOfSegments] - 1);
        [self fixSegements];
        [self changeInstruments];
    }
    else{
        [_instrumentController setSelectedSegmentIndex:prevSelect];
        [_fullGrid changeLayer:prevSelect -1];
    }
    
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
    if(![_fullGrid isPlaying]){
        [_tempoField resignFirstResponder];
        UIAlertView * tempoAlert = [[UIAlertView alloc] initWithTitle:@"Change Tempo" message:[NSString stringWithFormat:@"Min tempo: %d Max tempo: %d" ,MIN_TEMPO, MAX_TEMPO]     delegate:self cancelButtonTitle:nil otherButtonTitles:@"Change", nil];
        tempoAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [tempoAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
        [tempoAlert textFieldAtIndex:0].text = _tempoField.text;
        [tempoAlert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(alertView.alertViewStyle ==UIAlertViewStylePlainTextInput)
        _tempoField.text =  [alertView textFieldAtIndex:0].text;
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
        [sender setImage:[UIImage imageNamed:@"play"]];
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

+(EditMode)CURRENT_EDIT_MODE{
    return CURRENT_EDIT_MODE;
}
+(BOOL)LOOPING{
    return LOOPING;
}

@end

