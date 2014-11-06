//
//  ShopViewController.h
//  RingSynth
//
//  Created by Nir Boneh on 11/2/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AxonixAdView.h"
#import "PurchaseView.h"
#import "Assets.h"
#import "FilesViewController.h"


@interface ShopViewController : UIViewController<SKPaymentTransactionObserver>{
    NSMutableArray *purchaseViews;
}
@property AxonixAdView *bannerView;
@end
