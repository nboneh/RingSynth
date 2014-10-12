//
//  DetailViewController.m
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "DetailViewController.h"
#import <objc/message.h>

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
        if(text == nil)
            _detailDescriptionLabel.text = _name;
        else
            _detailDescriptionLabel.text = text;
        
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
    
}

-(void) viewDidAppear:(BOOL)animated{
   [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft]
                                forKey:@"orientation"];
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
     [NSKeyedArchiver archiveRootObject:_detailDescriptionLabel.text toFile:[self getPath:(id) _name]];
}

- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}

@end
