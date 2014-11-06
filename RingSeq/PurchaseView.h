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

@interface PurchaseView : UIView<UIAlertViewDelegate>{
    NSString *bundleName;
    NSString *sampleName;
    UIButton *playSampleButton;
    NSTimer *stopSampleTimer;
    float price;
}


-(id)initWithFrame:(CGRect)frame andPackInfo:(NSDictionary *)packInfo;
@end
