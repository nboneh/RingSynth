//
//  FilesViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface FilesViewController : UITableViewController<UIAlertViewDelegate, UITextFieldDelegate>{
    int addOrigHeight;
    NSArray *searchResults;
    NSString *fileToBeDeleted;
    BOOL performSegueOnce;
}
@property NSMutableArray *ringtones;
@property (strong, nonatomic) DetailViewController *detailViewController;
-(IBAction) addItem;




@end

