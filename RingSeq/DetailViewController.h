//
//  DetailViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "NoteDescription.h"
#import "Note.h"


@interface DetailViewController : UIViewController<UITextFieldDelegate>{
    BOOL firstTimeLoadingSubView;
}

typedef enum {
    insert =0,
    modify = 1,
    nerase = 2
} EditMode;

@property (strong, nonatomic) id name;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *instrumentController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accidentalsController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editModeController;

@property Note * noteBeingMoved;
@property Instrument *currentInstrument;
@property Accidental currentAccidental;
@property EditMode currentEditMode;

-(IBAction)changeEditingMode;
-(IBAction)changeInstrument;
-(IBAction)changeAccedintal;


@end

