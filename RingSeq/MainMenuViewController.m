//
//  MainMenuViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 10/29/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "MainMenuViewController.h"
#import "FilesViewController.h"
#import "Assets.h"
#import "Instrument.h"

@implementation MainMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [_curtain addGestureRecognizer:singleFingerTap];
    [_curtain setUserInteractionEnabled:YES];
    isAnimating = NO;
    currentlyAnimating = NO;

}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *controller = [segue destinationViewController];
    controller.navigationItem.backBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void) viewDidLayoutSubviews{
    //Curtain Animation
    if(isAnimating && !currentlyAnimating){
        currentlyAnimating = YES;
        [UIView animateWithDuration:2
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             CGRect frame = _curtain.frame;
             frame.origin.y = -frame.size.height + frame.size.height/8;
             [_curtain setFrame:frame];
             [_spotLight setAlpha:1.0f];
             
         }  completion:^(BOOL finished)
         {
             [currentInstrument playRandomNote];
             [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
                    CGRect frame = instrView.frame;
                     frame.origin.y -= 5;
                     instrView.frame = frame;
             }completion:nil];
             
             
             
             [UIView animateWithDuration:2
                                   delay:0.1
                                 options: UIViewAnimationOptionCurveEaseInOut
                              animations:^
              {
                  CGRect frame = _curtain.frame;
                  frame.origin.y = 0;
                  _curtain.frame = frame;
                  [_spotLight setAlpha:0.0f];
                  
              }
                              completion:^(BOOL finished2){
                                  isAnimating = NO;
                                  currentlyAnimating= NO;
                                  [instrView removeFromSuperview];
                              }];
             
         }];
    }
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if(isAnimating)
        return;
    
    isAnimating = YES;
    NSArray * instruments =[Assets INSTRUMENTS];
    currentInstrument= [instruments objectAtIndex: arc4random_uniform((int)instruments.count)];
    instrView = [[UIImageView alloc] initWithImage:currentInstrument.image];
    instrView.center = _stageView.center;
    instrView.tintColor = currentInstrument.color;
    [_stageView addSubview:instrView];
    
    
}
@end
