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
    NSMutableDictionary *fileToBeDeleted;
    BOOL performSegueOnce;
      UIAlertView * inAppPurchaseAlert;
}
@property (strong, nonatomic) InstrumentViewController *instrumentViewController;
-(IBAction) addItem;

+(NSDictionary *)INSTRUMENT_LIST;
+(void)SAVE_INSTRUMENT_LIST;



@end
