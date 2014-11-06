//
//  PurchaseView.m
//  RingSynth
//
//  Created by Nir Boneh on 11/4/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "PurchaseView.h"

@implementation PurchaseView
-(id)initWithFrame:(CGRect)frame andPackInfo:(NSDictionary *)packInfo{
    self = [super initWithFrame:frame];
    if(self){
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(stopSample)
                                                     name: @"backgroundMusicStopped"
                                                   object: nil];
        
        int nameWidth = self.frame.size.width/4 + 4;
        int instDistance = frame.size.width/8;
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, nameWidth, self.frame.size.height)];
        bundleName = [packInfo objectForKey:@"name"];
        price = [[packInfo objectForKey:@"price"] floatValue];
        labelName.text = [NSString stringWithFormat:@"%@($%.2f)" ,bundleName,price];
        [self addSubview:labelName];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Increasing size of font if on ipad
            [labelName setFont:[UIFont systemFontOfSize:25]];
            
        } else{
            [labelName setFont:[UIFont systemFontOfSize:13]];
        }
        
        NSArray * instruments = [packInfo objectForKey:@"instruments"];
        for(int i = 0; i < instruments.count; i++){
            InstrumentPurchaseView* instrView = [[InstrumentPurchaseView alloc] initWitInstrument:[instruments objectAtIndex:i] andX:i*instDistance + nameWidth+ 10];
            CGRect instrFrame = instrView.frame;
            instrFrame.origin.y = self.frame.size.height/2 - instrFrame.size.height/2;
            instrView.frame = instrFrame;
            [self addSubview:instrView];
        }
        int playWidth = self.frame.size.width/5;
        int xOfSample = (int)instruments.count * instDistance + nameWidth ;
        playSampleButton =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
        playSampleButton.frame= CGRectMake(xOfSample, 0, playWidth, self.frame.size.height);
        playSampleButton.titleLabel.textColor = self.tintColor;
        [playSampleButton setTitle:@"Play Sample" forState:UIControlStateNormal];
        [playSampleButton addTarget:self
                             action:@selector(playSample:)
                   forControlEvents:UIControlEventTouchUpInside];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Increasing size of font if on ipad
            [playSampleButton.titleLabel  setFont:[UIFont systemFontOfSize:25]];
            
        } else{
            [playSampleButton.titleLabel  setFont:[UIFont systemFontOfSize:13]];
        }
        sampleName= [packInfo objectForKey:@"samplename"];
        [self addSubview:playSampleButton];
        
        UIButton * purchaseButton =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
        purchaseButton.frame= CGRectMake(xOfSample + playWidth , 0, playWidth, self.frame.size.height);
        purchaseButton.titleLabel.textColor = self.tintColor;
        [purchaseButton setTitle:@"Purchase" forState:UIControlStateNormal];
        [purchaseButton addTarget:self
                           action:@selector(requestPurchase)
                 forControlEvents:UIControlEventTouchUpInside];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
        {
            //Increasing size of font if on ipad
            [purchaseButton.titleLabel  setFont:[UIFont systemFontOfSize:25]];
            
        } else{
            [purchaseButton.titleLabel  setFont:[UIFont systemFontOfSize:13]];
        }
        [self addSubview:purchaseButton];
        
        bundleIdentifier = [packInfo objectForKey:@"identifier"];
        
    }
    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    [UIView animateKeyframesWithDuration:0.2 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        CGRect frame = view.frame;
        frame.origin.y -= 5;
        view.frame = frame;
    }completion:nil];
}

-(void)playSample:(UIButton *)button{
    if([button.titleLabel.text isEqualToString:@"Play Sample"]){
        [[OALSimpleAudio sharedInstance] stopBg];
        stopSampleTimer =[NSTimer scheduledTimerWithTimeInterval:[self durationOfSample]
                                                          target:self
                                                        selector:@selector(stopSample)
                                                        userInfo:nil
                                                         repeats:NO];
        
        [button setTitle:@"Stop Sample" forState:UIControlStateNormal];
        [[OALSimpleAudio sharedInstance] playBg:[NSString stringWithFormat:@"%@.m4a", sampleName]];
    } else{
        [[OALSimpleAudio sharedInstance] stopBg];
    }
    
}

-(void)stopSample{
    [playSampleButton setTitle:@"Play Sample" forState:UIControlStateNormal];
    [stopSampleTimer  invalidate];
    stopSampleTimer = nil;
}

-(float) durationOfSample{
    NSString *musicPaths  =[[NSBundle mainBundle] pathForResource:sampleName ofType:@"m4a"];
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:musicPaths]  options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return  audioDurationSeconds;
}

-(void)requestPurchase{
    if([SKPaymentQueue canMakePayments]){
        UIAlertView *purchaseAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Buy %@", bundleName]  message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
        [purchaseAlert show];
    }
    else{
        UIAlertView *noPurchaseAlert = [[UIAlertView alloc] initWithTitle:@"User can't make payments" message:@"" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [noPurchaseAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        //Buy option
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:bundleIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}


@end
