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
#import "FullGrid.h"
#import "SlidingSegment.h"


@interface DetailViewController : UIViewController<UIAlertViewDelegate, UIActionSheetDelegate>{
    BOOL firstTimeLoadingSubView;
    NSMutableArray *instruments;
    int prevSelect;
    UIAlertView * tempoAlert;
    UIAlertView *beatAlert;
}

typedef enum {
    insert,
    nerase
} EditMode;

@property (weak, nonatomic) IBOutlet UITextField *beatsTextField;

@property (strong, nonatomic) id name;

@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UITextField *tempoField;
@property  SlidingSegment *instrumentController;
@property FullGrid* fullGrid;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

-(IBAction)changeTempo;
-(IBAction)replay;
-(IBAction)changeAccedintal:(UISegmentedControl *)sender;
-(IBAction)changeEditMode:(UISegmentedControl *)sender;
-(IBAction)play:(UIBarButtonItem*)sender;
-(IBAction)loop:(UIBarButtonItem*)sender;
-(IBAction)changeBeat;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBar;

+(Instrument *)CURRENT_INSTRUMENT;
+(Accidental)CURRENT_ACCIDENTAL;
+(EditMode)CURRENT_EDIT_MODE;
+(BOOL)LOOPING;
@end

