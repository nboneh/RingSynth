//
//  EditorViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 1/2/15.
//  Copyright (c) 2015 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditorViewController : UIViewController


typedef enum {
    duplicatet = 0,
    movet = 1,
    eraset = 2
} EditingMode;

@property (weak, nonatomic) IBOutlet UIView *insertView;
@property (weak, nonatomic) IBOutlet UIView *acceptView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *editModeControl;
@property (nonatomic, weak) IBOutlet UIView *supportViewPopupBackground;
@property (nonatomic, weak) IBOutlet UIView *supportViewPopupAction; // The white view with outlets
// Property for customize the UI of this alert (you can add other labels, buttons, tableview, etc.
@property (nonatomic, weak) IBOutlet UIButton *buttonOK;
@property (nonatomic, weak) IBOutlet UIButton *buttonCancel;
@property (nonatomic, weak) IBOutlet UILabel *labelDescription;


- (void)displayPopup;
- (void)dismissModal;

-(IBAction)okClicked;

-(IBAction)cancelClicked;

-(IBAction)editModeChanged:(id)sender;
@end
