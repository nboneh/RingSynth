//
//  PurchaseView.h
//  RingSynth
//
//  Created by Nir Boneh on 11/4/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "InstrumentPurchaseView.h"
#import "OALSimpleAudio.h"
#import <StoreKit/StoreKit.h>

@interface PurchaseView : UIView<UIAlertViewDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>{
    NSString *bundleName;
    NSString *sampleName;
    UIButton *playSampleButton;
    NSTimer *stopSampleTimer;
    float price;
    NSString *bundleIdentifier;
    BOOL purchased;
    UIButton * purchaseButton ;
    NSArray * instruments;
}

-(id)initWithFrame:(CGRect)frame andPackInfo:(NSDictionary *)packInfo;
-(void)setAsPurchased;
@end
