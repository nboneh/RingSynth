
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

@end

@implementation DetailViewController

@synthesize bottomBar = _bottomBar;
static const int MIN_TEMPO =11;
static const int MAX_TEMPO = 500;

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
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(enteredBackground:)
                   name: @"didEnterBackground"
                 object: nil];

    NSArray* instruments = [Assets getInstruments];
    NSInteger size = [instruments count];
    firstTimeLoadingSubView = YES;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}
-(void) viewDidLayoutSubviews{
    if(firstTimeLoadingSubView) {
    
            
        _fullGrid = [[FullGrid alloc] initWithFrame:self.view.frame ];
        [self.view addSubview:_fullGrid];
       // [self.view addSubview:staff];
        //[self.view addSubview:layout];
        [self.view bringSubviewToFront: _bottomBar];
    }
    firstTimeLoadingSubView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)enteredBackground:(NSNotification *)notification{
    //Saving file
    [self save];
    
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    NSString *text = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];

    int newTempo = [text intValue];
    return newTempo <= MAX_TEMPO && newTempo >= MIN_TEMPO;
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
    [_fullGrid replay];
}
-(IBAction)changeTempo{
    [_tempoField resignFirstResponder];
    UIAlertView * tempoAlert = [[UIAlertView alloc] initWithTitle:@"Change Tempo" message:@""   delegate:self cancelButtonTitle:nil otherButtonTitles:@"Change", nil];
    tempoAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [tempoAlert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [tempoAlert textFieldAtIndex:0].text = _tempoField.text;
    [tempoAlert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    _tempoField.text =  [alertView textFieldAtIndex:0].text;
}
- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}


@end

