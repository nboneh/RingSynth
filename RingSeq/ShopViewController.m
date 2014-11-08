//
//  ShopViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 11/2/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "ShopViewController.h"

@implementation ShopViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
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
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(resignActive)
                   name: @"applicationWillResignActive"
                 object: nil];
    
    
    
    CGRect frame = self.view.frame;
    NSArray *packs = [Assets IN_APP_PURCHASE_PACKS];
    int i = 0;
    int ydist  =  frame.size.height/8;
    int heightStart =  [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.toolbar.frame.size.height+ ydist/2;
    purchaseViews = [[NSMutableArray alloc] init];
    for(NSDictionary * pack in packs){
        PurchaseView* pView = [[PurchaseView alloc] initWithFrame:CGRectMake(0, ydist*i +heightStart, frame.size.width, ydist/2) packInfo:pack];
        [self.view addSubview: pView];
        [purchaseViews addObject:pView];
        i++;
    }
    UIButton * restorePurchases =   [UIButton buttonWithType:UIButtonTypeRoundedRect];
    restorePurchases.frame= CGRectMake(0, ydist*i + heightStart, self.view.frame.size.width,frame.size.height/6);
    [restorePurchases setTitle:@"Restore purchases" forState:UIControlStateNormal];
    [restorePurchases addTarget:self
                         action:@selector(restorePurchases)
               forControlEvents:UIControlEventTouchUpInside];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        //Increasing size of font if on ipad
        [restorePurchases.titleLabel  setFont:[UIFont systemFontOfSize:25]];
        
    } else{
        [restorePurchases.titleLabel  setFont:[UIFont systemFontOfSize:13]];
    }
    [self.view addSubview:restorePurchases];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bannerView pauseAdAutoRefresh];
    
    [[OALSimpleAudio sharedInstance] stopBg];
    for(PurchaseView * purchaseView in purchaseViews){
        
        [[NSNotificationCenter defaultCenter] removeObserver:purchaseView];
    }
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.bannerView resumeAdAutoRefresh];
}
-(void)resignActive{
    [[OALSimpleAudio sharedInstance] stopBg];
}
-(void)restorePurchases{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", (int)queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transaction state -> Restored");
            //called when the user successfully restores a purchase
            [self validatePurchaseTransaction:transaction];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
        
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                // [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [self validatePurchaseTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [self validatePurchaseTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case  SKPaymentTransactionStateDeferred:
                //Child asking for approval from parent wait it out
                break;
        }
    }
}

-(void)validatePurchaseTransaction:(SKPaymentTransaction *) transaction{
    NSString * identifier = transaction.payment.productIdentifier;
    for(PurchaseView * pView in purchaseViews){
        if([pView.identifier isEqualToString:identifier]){
            [pView setAsPurchased];
            break;
        }
    }
}
@end
