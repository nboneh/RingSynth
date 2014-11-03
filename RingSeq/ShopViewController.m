//
//  ShopViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 11/2/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "ShopViewController.h"

@interface ShopViewController ()

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        self.bannerView = [[AxonixAdViewiPad_728x90 alloc] init];
    else
        self.bannerView = [[AxonixAdViewiPhone_320x50 alloc] init];
    CGRect frame = self.bannerView.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    frame.origin.x = self.view.frame.size.width/2 - frame.size.width/2;
    self.bannerView.frame = frame;
    [self.view addSubview:self.bannerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bannerView pauseAdAutoRefresh];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.bannerView resumeAdAutoRefresh];
}


@end
