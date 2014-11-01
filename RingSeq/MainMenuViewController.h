//
//  MainMenuViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 10/29/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"

@interface MainMenuViewController : UIViewController{
    BOOL isAnimating;
    BOOL currentlyAnimating;
    UIImageView * instrView;
    Instrument*currentInstrument;
}
@property (weak, nonatomic) IBOutlet UIImageView *stageView;
@property (weak, nonatomic) IBOutlet UIImageView *curtain;
@property (weak, nonatomic) IBOutlet UIImageView *spotLight;

@end
