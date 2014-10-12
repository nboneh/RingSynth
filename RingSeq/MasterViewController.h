//
//  MasterViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<UIAlertViewDelegate, UITextFieldDelegate>{
    int addOrigHeight;
    NSArray *searchResults;
    NSString *fileToBeDeleted;
    NSMutableArray *ringtones;
}

@property (strong, nonatomic) DetailViewController *detailViewController;
-(IBAction) addItem;




@end

