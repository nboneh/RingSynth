//
//  DetailViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Measure.h"

@interface DetailViewController : UIViewController<UITextFieldDelegate>{
    Measure *measure;
    BOOL firstTimeLoadingSubView;
}

@property (strong, nonatomic) id name;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *instrumentController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accidentalsController;

-(IBAction)changeInstrument;
-(IBAction)changeAccedintal;


@end

