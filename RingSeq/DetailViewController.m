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
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enteredBackground:)
                                                 name: @"didEnterBackground"
                                               object: nil];
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
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)enteredBackground:(NSNotification *)notification{
    //Saving file
    [NSKeyedArchiver archiveRootObject:_detailDescriptionLabel.text toFile:[self getPath:(id) _name]];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    //View will disappear save music
    [NSKeyedArchiver archiveRootObject:_detailDescriptionLabel.text toFile:[self getPath:(id) _name]];
    [super viewWillDisappear:animated];
}

- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}

@end
