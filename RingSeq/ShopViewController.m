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
    CGRect bannerFrame = self.bannerView.frame;
    bannerFrame.origin.y = self.view.frame.size.height - bannerFrame.size.height;
    bannerFrame.origin.x = self.view.frame.size.width/2 - bannerFrame.size.width/2;
    self.bannerView.frame = bannerFrame;
    [self.view addSubview:self.bannerView];
    
    
    CGRect frame = self.view.frame;
    NSArray *packs = [Assets IN_APP_PURCHASE_PACKS];
    int i = 0;
    int ydist  =  frame.size.height/8;
    int heightStart =  [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.toolbar.frame.size.height+ ydist/2;
    for(NSDictionary * pack in packs){
        PurchaseView* pView = [[PurchaseView alloc] initWithFrame:CGRectMake(0, ydist*i +heightStart, frame.size.width, ydist/2) andPackInfo:pack];
        [self.view addSubview: pView];
        i++;
    }
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
