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
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Increasing size of font if on ipad
        [_pinchHelp setFont:[UIFont systemFontOfSize:60]];
        
    }
    
    [_pinchHelp  setAlpha:0.0f];
    
    //fade in
    [UIView animateWithDuration:2.0f animations:^{
        
        [_pinchHelp  setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        //fade out
        [UIView animateWithDuration:3.0f animations:^{
            
            [_pinchHelp  setAlpha:0.0f];
            
        } completion:nil];
        
    }];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _helpView;
}
-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    [_pinchHelp.layer removeAllAnimations];
           [_pinchHelp  setAlpha:0.0f];
}

@end
