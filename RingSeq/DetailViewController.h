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


@interface DetailViewController : UIViewController<UIAlertViewDelegate>{
    BOOL firstTimeLoadingSubView;
}


@property (strong, nonatomic) id name;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UITextField *tempoField;
@property FullGrid* fullGrid;


-(IBAction)changeTempo;
-(IBAction)replay;


@end

