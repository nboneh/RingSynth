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


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if(isAnimating)
        return;
    //Remove the instrument from the stage
    NSArray *viewsToRemove = [_stageView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }

    isAnimating = YES;
    NSArray * instruments =[Assets INSTRUMENTS];
    Instrument * instrument = [instruments objectAtIndex: arc4random_uniform((int)instruments.count)];
    UIImageView *instrView = [[UIImageView alloc] initWithImage:instrument.image];
    instrView.center = _stageView.center;
    instrView.tintColor = instrument.color;
    [_stageView addSubview:instrView];
    
    //Curtain Animation
    [UIView animateWithDuration:2
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         CGRect frame = _curtain.frame;
         frame.origin.y = -(frame.size.height);
         [_curtain setFrame:frame];
         [_spotLight setAlpha:1.0f];
         
     }  completion:^(BOOL finished)
     {
         isAnimating = NO;
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
                    }];
         
     }];
    
    
}
@end
