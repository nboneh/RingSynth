
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
#import "FullGrid.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize bottomBar = _bottomBar;
@synthesize currentInstrument = _currentInstrument;
@synthesize currentAccidental = _currentAccidental;
static const int minTempo =11;
FullGrid *fullGrid;

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
       fullGrid =[NSKeyedUnarchiver unarchiveObjectWithFile:[self getPath:(id)_name]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(enteredBackground:)
                   name: @"didEnterBackground"
                 object: nil];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardOffScreen:) name:UIKeyboardDidHideNotification object:nil];
    NSArray* instruments = [Assets getInstruments];
    NSInteger size = [instruments count];
    [_instrumentController removeSegmentAtIndex:0 animated:NO];
    [_instrumentController removeSegmentAtIndex:0 animated:NO];
    for(int i = 0; i < size; i++){
        Instrument *instr = [instruments objectAtIndex:i];
        [_instrumentController insertSegmentWithTitle:instr.name atIndex:i animated:NO];
        [_instrumentController setImage:instr.image forSegmentAtIndex:i];
        [[[_instrumentController subviews] objectAtIndex:i] setTintColor:instr.color];
    }
    [_instrumentController insertSegmentWithTitle:@"All" atIndex:0 animated:NO];
    [_instrumentController setSelectedSegmentIndex:0];
    firstTimeLoadingSubView = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}
-(void) viewDidLayoutSubviews{
    if(firstTimeLoadingSubView) {
    
            
        fullGrid = [[FullGrid alloc] initWithEnv:self ];
        [self.view addSubview:fullGrid];
       // [self.view addSubview:staff];
        //[self.view addSubview:layout];
        [self.view bringSubviewToFront: _bottomBar];
        [self.view bringSubviewToFront:_instrumentController];
    }
    firstTimeLoadingSubView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)changeInstrument:(UISegmentedControl *)sender{
    int pos = (int)[sender selectedSegmentIndex] -1;
    if(pos >= 0)
        _currentInstrument = [[Assets getInstruments] objectAtIndex:pos];
    else
        _currentInstrument = nil;
}
-(IBAction)changeAccedintal:(UISegmentedControl *)sender{
    _currentAccidental = (Accidental)[sender selectedSegmentIndex];
    
}

-(IBAction)changeEditingMode:(UISegmentedControl *) sender{
    _currentEditMode =(EditMode)[sender selectedSegmentIndex];
}

-(void)enteredBackground:(NSNotification *)notification{
    //Saving file
    [self save];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //Tempo should not be larger than 3 digits
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 3) ? NO : YES;
}

-(void)keyboardOnScreen:(NSNotification *)notification{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    CGRect frame = _bottomBar.frame;
    frame.origin.y -= keyboardFrame.size.height;
    _bottomBar.frame = frame;
    
    
}

-(void)keyboardOffScreen:(NSNotification *)notification{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    CGRect frame = _bottomBar.frame;
    frame.origin.y += keyboardFrame.size.height;
    _bottomBar.frame = frame;
    
    if(_tempoField.text.integerValue < minTempo){
        _tempoField.text = [@(minTempo) stringValue];
    }
    [self.view bringSubviewToFront: _bottomBar];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.view endEditing:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    //View will disappear save music
    [self save];
    [super viewWillDisappear:animated];
}

-(void) save{
  //  [NSKeyedArchiver archiveRootObject:fullGrid toFile:[self getPath:(id) _name]];
}

-(IBAction)replay{
    [fullGrid replay];
}

- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}



@end

