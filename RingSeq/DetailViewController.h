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
}


@property (strong, nonatomic) id name;

@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UITextField *tempoField;
@property  SlidingSegment *instrumentController;
@property FullGrid* fullGrid;


-(IBAction)changeTempo;
-(IBAction)replay;
-(IBAction)changeAccedintal:(UISegmentedControl *)sender;
-(IBAction)pressPlay;
-(IBAction)pressStop;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBar;

+(Instrument *)CURRENT_INSTRUMENT;
+(Accidental)CURRENT_ACCIDENTAL;

@end

