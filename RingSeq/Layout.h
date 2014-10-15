//
//  Layout.h
//  RingSeq
//
//  Created by Nir Boneh on 10/15/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Staff.h"
#import "DetailViewController.h"

@interface Layout : UIView{
    NSArray *measures;
}


-(id) initWithStaff:(Staff *)staff env: (DetailViewController *) env;
@end
