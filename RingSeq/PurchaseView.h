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

@interface PurchaseView : UIView<SKProductsRequestDelegate>{
    NSString *bundleName;
    NSString *sampleName;
    UIButton *playSampleButton;
    NSTimer *stopSampleTimer;
    float price;
    BOOL purchased;
    UIButton * purchaseButton ;
    NSArray * instruments;
}
@property NSString * identifier;
-(id)initWithFrame:(CGRect)frame packInfo:(NSDictionary *)packInfo;
-(void)setAsPurchased;
@end
