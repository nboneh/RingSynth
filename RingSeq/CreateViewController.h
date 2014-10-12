//
//  CreateViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"

@interface CreateViewController : UIViewController

@property (retain, nonatomic)  MasterViewController *parentController;
@property (weak, nonatomic) IBOutlet UITextField *nameField;


-(IBAction) create;
-(IBAction) cancel;
@end
