//
//  MainMenuViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 10/29/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "StringView.h"

@interface MainMenuViewController : UIViewController<StringViewDelegate>{
    BOOL isAnimating;
    BOOL currentlyAnimating;
    UIImageView * instrView;
    Instrument*currentInstrument;
    StringView*stringView;
    UIImageView *spotLight;
}
@property (weak, nonatomic) IBOutlet UIImageView *stageView;
@property (weak, nonatomic) IBOutlet UIImageView *curtain;

@end
