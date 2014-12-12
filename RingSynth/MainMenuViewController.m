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
    

    [self adjustButton:self.createButton];
    [self adjustButton:self.helpButton];
    [self adjustButton:self.shopButton];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [self.mainTitle setFont:[self.mainTitle.font fontWithSize:70]];
    }
    
    
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

-(void)adjustButton:(UIButton *)button{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintWidth, *constraintHeight;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Increasing size of font if on ipad
        [button.titleLabel  setFont:[UIFont systemFontOfSize:30]];
        constraintWidth = [NSLayoutConstraint constraintWithItem:button
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0
                                                        constant:150];
        
        
        
        constraintHeight = [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationLessThanOrEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:0
                                                         constant:75];
        
        
    } else{
        
        
        
        constraintWidth = [NSLayoutConstraint constraintWithItem:button
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0
                                                        constant:75];
        
        
        constraintHeight= [NSLayoutConstraint constraintWithItem:button
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationLessThanOrEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0
                                                        constant:45];
        
        
    }
    [button addConstraint:constraintHeight];
    [button addConstraint:constraintWidth];
    [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
    
    
}
@end
