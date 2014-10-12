//
//  DetailViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id name;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

