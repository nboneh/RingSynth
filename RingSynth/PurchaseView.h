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
#import <AVFoundation/AVFoundation.h>

@interface PurchaseView : UIView<SKProductsRequestDelegate, AVAudioPlayerDelegate>{
    NSString *bundleName;
    NSString *sampleName;
    UIButton *playSampleButton;
    float price;
       AVAudioPlayer *player;
    UIButton * purchaseButton ;
    NSArray * instruments;
    NSMutableArray *instrViews;
}
@property NSString * identifier;
@property (nonatomic)BOOL purchased;
-(id)initWithFrame:(CGRect)frame packInfo:(NSDictionary *)packInfo;
-(void) removeAllNotifications;
@end
