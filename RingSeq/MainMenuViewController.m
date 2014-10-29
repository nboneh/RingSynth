//
//  MainMenuViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 10/29/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "MainMenuViewController.h"
#import "FilesViewController.h"

@implementation MainMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showFiles"]) {
        FilesViewController *controller = (FilesViewController *)[segue destinationViewController];
        controller.navigationItem.backBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
       self.navigationController.navigationBar.hidden = YES;
}

@end
