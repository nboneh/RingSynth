//
//  MainMenuViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 10/29/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"

@interface MainMenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;

@property (weak, nonatomic) IBOutlet UIButton *makeButton;

@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *shopButton;



@end
