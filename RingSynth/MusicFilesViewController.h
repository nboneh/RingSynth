//
//  MusicFilesViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicViewController;

@interface MusicFilesViewController : UITableViewController<UIAlertViewDelegate, UITextFieldDelegate>{
    int addOrigHeight;
    NSArray *searchResults;
    NSString *fileToBeDeleted;
    BOOL performSegueOnce;
}
@property (strong, nonatomic) MusicViewController *musicViewController;
-(IBAction) addItem;

+(NSMutableArray *)RINGTONE_LIST;
+(void)SAVE_RINGTONE_LIST;




@end

