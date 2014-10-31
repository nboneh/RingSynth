//
//  HelpViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 10/30/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    UIScrollView* scrollView = (UIScrollView *)self.view;
      scrollView.scrollEnabled = YES;
    scrollView.maximumZoomScale = 6.5f;
    [(UIScrollView *)self.view setDelegate:self];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _container;
}

@end
