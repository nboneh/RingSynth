//
//  EditorViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 1/2/15.
//  Copyright (c) 2015 Clouby. All rights reserved.
//

#import "EditorViewController.h"

@interface EditorViewController ()

@end

@implementation EditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Support View
    self.supportViewPopupAction.layer.cornerRadius = 5.0f;
    self.supportViewPopupAction.layer.masksToBounds = YES;
    
    UIView * mainView = [[[UIApplication sharedApplication] delegate] window] ;
    
    self.supportViewPopupBackground.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:.5];
    self.supportViewPopupBackground.frame = mainView.frame;
    
    self.supportViewPopupAction.alpha = 0.0f;
    
}
- (void)displayPopup;
{
    // Support View
    UIView * mainView = [[[UIApplication sharedApplication] delegate] window] ;
    [mainView addSubview: self.view];
    [self fixFrame];
    
    // Animation
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.supportViewPopupAction.alpha = 1.0f;
                     }  ];
}

- (void)dismissModal
{
    // Animation
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.supportViewPopupAction.alpha = 0.0f;
                     } completion:^(BOOL finished){[self.view removeFromSuperview];}];
}

-(IBAction)okClicked{
    [self dismissModal];
}

-(IBAction)cancelClicked{
    [self dismissModal];
}

-(IBAction)editModeChanged:(id)sender{
    if([sender selectedSegmentIndex] == eraset){
        [_insertView setHidden:YES];
        CGRect frame = _acceptView.frame;
        frame.origin.y = _insertView.frame.origin.y;
        _acceptView.frame = frame;
    } else {
        [_insertView setHidden:NO];
        CGRect frame = _acceptView.frame;
        frame.origin.y = _insertView.frame.origin.y + _insertView.frame.size.height;
        _acceptView.frame = frame;
    }
    [self fixFrame];
}

-(void) fixFrame{
    CGRect frame   =  self.supportViewPopupAction.frame;
    frame.size.height =  _acceptView.frame.origin.y + _acceptView.frame.size.height;
    self.supportViewPopupAction.frame = frame;
    UIView * mainView = [[[UIApplication sharedApplication] delegate] window] ;
    self.supportViewPopupAction.center = mainView.center;
}
@end
