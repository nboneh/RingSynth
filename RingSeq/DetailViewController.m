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
#import "Measure.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

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
        NSString *text =[NSKeyedUnarchiver unarchiveObjectWithFile:[self getPath:(id)_name]];
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
        [_instrumentController setImage:instr.getImage forSegmentAtIndex:i];
    }
    [_instrumentController insertSegmentWithTitle:@"Showtime" atIndex:0 animated:NO];
    [_instrumentController setSelectedSegmentIndex:0];
    
    firstTimeLoadingSubView = YES;

    
}
-(void) viewDidLayoutSubviews{
    if(firstTimeLoadingSubView) {
        int startY = _instrumentController.frame.origin.y  + _instrumentController.frame.size.height;
        Staff *staff = [[Staff alloc] initWithFrame:CGRectMake(0,startY +20, self.view.frame.size.width, _bottomBar.frame.origin.y - startY-40)];
        [self.view addSubview:staff];
        measure = [[Measure alloc] initWithStaff:staff andX:80 andVolumeMeterHeight:35];
        [self.view addSubview:measure];
    }
    firstTimeLoadingSubView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)changeInstrument{
    NSInteger index = [_instrumentController selectedSegmentIndex] -1;
    if(index >= 0){
        measure.instrument = [[Assets getInstruments] objectAtIndex:index];
    }

}
-(IBAction)changeAccedintal{
    measure.accedintal = (int)[_accidentalsController selectedSegmentIndex];

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
     [NSKeyedArchiver archiveRootObject:@"" toFile:[self getPath:(id) _name]];
}


- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}

@end
