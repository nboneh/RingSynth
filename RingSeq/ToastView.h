//
//  ToastView.h
//  World Magnetic Model
//
//  Created by Nir Boneh on 6/17/14.
//  Copyright (c) 2014 NOAA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToastView : UIView

@property (strong, nonatomic) UILabel *textLabel;
+ (void)showToastWithText:(NSString *)text withDuaration:(float)duration;
@end
