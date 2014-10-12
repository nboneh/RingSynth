//
//  NSObject+Rotation.m
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "NSObject+Rotation.h"

@implementation ViewController (Rotation)
- (NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations = %d ", [self.topViewController         supportedInterfaceOrientations]);
    
    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    // You do not need this method if you are not supporting earlier iOS Versions
    
    return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
@end
