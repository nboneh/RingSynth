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
    
    stringView = [[StringView alloc] initWithX:self.view.frame.size.width * .8f andDelegate:self];
    [self.view addSubview:stringView];
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
             [spotLight setAlpha:0.6f];
             
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
                  [spotLight setAlpha:0.0f];
                  
              }
                              completion:^(BOOL finished2){
                                  isAnimating = NO;
                                  currentlyAnimating= NO;
                                  [instrView removeFromSuperview];
                              }];
             
         }];
    }
    
}

-(void)stringActivated{
    if(isAnimating)
        return;
    
    isAnimating = YES;
    NSArray * instruments =[Assets INSTRUMENTS];
    currentInstrument= [instruments objectAtIndex: arc4random_uniform((int)instruments.count)];
    instrView = [[UIImageView alloc] initWithImage:currentInstrument.image];
    instrView.tintColor = currentInstrument.color;
        instrView.center = _stageView.center;
    
    CGRect frame =instrView.frame;
    frame.origin.x  = _stageView.frame.size.width/2 - frame.size.width/2;
    instrView.frame = frame;
    [_stageView addSubview:instrView];
    if(!spotLight){
        spotLight = [[UIImageView alloc ] initWithImage:[UIImage imageNamed:@"spotlight"]];
        CGRect frame  = spotLight.frame;
        frame.size.height = instrView.frame.size.height * 2;
        frame.size.width = instrView.frame.size.width * 2;
        spotLight.frame =frame;
         spotLight.center = _stageView.center;
        [spotLight setAlpha:0];
        [self.view addSubview:spotLight];
    }

    

}
@end
