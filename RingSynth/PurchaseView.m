//
//  PurchaseView.m
//  RingSynth
//
//  Created by Nir Boneh on 11/4/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "PurchaseView.h"
#import "Assets.h"

@implementation PurchaseView
@synthesize identifier = _identifier;
@synthesize purchased = _purchased;
-(id)initWithFrame:(CGRect)frame packInfo:(NSDictionary *)packInfo{
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
        
        instruments = [packInfo objectForKey:@"instruments"];
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
        
        
        _identifier = [packInfo objectForKey:@"identifier"];
    
        _purchased =[[instruments objectAtIndex:0] purchased];
        
        purchaseButton =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
        purchaseButton.frame= CGRectMake(xOfSample + playWidth , 0, playWidth, self.frame.size.height);
        purchaseButton.titleLabel.textColor = self.tintColor;
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
        [self checkPurchaseButton];
        [self addSubview:purchaseButton];
        
        
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
    [purchaseButton setTitle:@"Buying..." forState:UIControlStateNormal];
    [purchaseButton setEnabled:NO];

    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:_identifier]];
    productsRequest.delegate = self;
    [productsRequest start];

}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

-(void)checkPurchaseButton{
    if(!_purchased){
        [purchaseButton setTitle:@"Purchase" forState:UIControlStateNormal];
        [purchaseButton setEnabled:YES];
    } else{
        [purchaseButton setTitle:@"Owned" forState:UIControlStateNormal];
        [purchaseButton setEnabled:NO];
    }
}
-(void)setPurchased:(BOOL)purchased{
    if(_purchased)
        return;
    _purchased = purchased;
    [self checkPurchaseButton];
    if(!purchased)
        return;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults] ;
    [userDefaults setBool:YES forKey:_identifier];
    [userDefaults synchronize];
    for(Instrument * instrument in instruments){
        instrument.purchased = YES;
    }
    
    //Adding sample song
    NSMutableArray *ringtones = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPath:(id)RING_TONE_LIST_FILE_NAME]];
    if(ringtones == nil){
        ringtones = [[NSMutableArray alloc] init];
    }
    
    
    NSString *musicPath  =[[NSBundle mainBundle] pathForResource:sampleName ofType:@""];
    NSData * data = [[NSData alloc] initWithContentsOfFile:musicPath];
    
    NSString *useName = sampleName;
    NSInteger size = [ringtones count];
    int k = 1;
    for(int i = 0; i < size; i++){
        NSString *ring = [ringtones objectAtIndex:i];
        if ([useName caseInsensitiveCompare:ring] == NSOrderedSame){
            //Can't have two ringtones with the same name if exists change the name
            useName = [NSString stringWithFormat:@"%@ (%d)",sampleName,k ];
            i = -1;
            k++;
        }
    }
    
    [ringtones insertObject:useName atIndex:0];
    [data writeToFile:[self getPath:useName] atomically:YES];
    [NSKeyedArchiver archiveRootObject:ringtones toFile:[self getPath:(id) RING_TONE_LIST_FILE_NAME]];
    
}
- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}

@end
