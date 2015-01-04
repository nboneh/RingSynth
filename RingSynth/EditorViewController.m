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
@synthesize totalPossibleBeats = _totalPossibleBeats;
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
    
    addBeatAmount = 4;
    
}
- (void)displayPopup:(NSString *) title totalBeats:(int)totalBeats startingValue:(int)num
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
    
    _fromStepper.maximumValue = totalBeats;
    _toStepper.maximumValue = totalBeats +1;
    _fromStepper.value = num;
    
    _toStepper.minimumValue = num  + 1;
    
    int toValue = num + addBeatAmount;
    if(toValue > _toStepper.maximumValue)
        toValue =  _toStepper.maximumValue;
    
    _toStepper.value = toValue;

    _insertStepper.maximumValue = _totalPossibleBeats - (_toStepper.value - _fromStepper.value) +1 ;

    int insertValue = toValue;
    if(insertValue > _insertStepper.maximumValue)
        insertValue = 1;
   
    _insertStepper.value = insertValue;
    
    _labelDescription.text = title;
    [self fixLabels];
    
}

- (void)dismissModal
{
    
    addBeatAmount = _toStepper.value - _fromStepper.value ;
    // Animation
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.supportViewPopupAction.alpha = 0.0f;
                     } completion:^(BOOL finished){[self.view removeFromSuperview];}];
}

-(IBAction)okClicked{
    [self dismissModal];
    if(_delegate){
        //Converting back to programming land where zero is start
        [_delegate  exitedWithStartBeat:(_fromStepper.value -1) endBeat:(_toStepper.value -1) insertBeat:(_insertStepper.value -1) EditingMode:(EditingMode)[_editModeControl selectedSegmentIndex]];
    }

}

-(IBAction)cancelClicked{
    [self dismissModal];
}

-(IBAction)incrementChanged:(id)sender{
    [self fixLabels];
}

-(void)fixLabels{
    _toStepper.minimumValue = _fromStepper.value  + 1;
    _insertStepper.maximumValue = _totalPossibleBeats - (_toStepper.value - _fromStepper.value) +1 ;
    
    [_toLabel setText:[NSString stringWithFormat:@"%d", (int)_toStepper.value]];
    
    [_fromLabel setText:[NSString stringWithFormat:@"%d",  (int)_fromStepper.value]];
    
    [_insertLabel setText:[NSString stringWithFormat:@"%d", (int)_insertStepper.value]];

    
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
