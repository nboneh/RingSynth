//
//  InstrumentsViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstrumentViewController.h"

@class InstrumentViewController;

@interface InstrumentFilesViewController : UITableViewController<UIAlertViewDelegate, UITextFieldDelegate>{
    int addOrigHeight;
    NSArray *searchResults;
    NSString *fileToBeDeleted;
    BOOL performSegueOnce;
}
@property (strong, nonatomic) InstrumentViewController *instrumentViewController;
-(IBAction) addItem;

+(NSMutableArray *)INSTRUMENT_LIST;
+(void)SAVE_INSTRUMENT_LIST;



@end
