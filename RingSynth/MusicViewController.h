//
//  MusicViewController.h
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instrument.h"
#import "NoteDescription.h"
#import "FullGrid.h"
#import "SlidingSegment.h"
#import <MessageUI/MessageUI.h>
#import "AxonixFullScreenAdViewController.h"
#import "EditorViewController.h"



@interface MusicViewController : UIViewController<UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate,UITextFieldDelegate, AxonixFullScreenAdDelegate>{
    BOOL firstTimeLoadingSubView;
    NSMutableArray *instruments;
    int prevSelect;
    EditorViewController * editViewController;
    UIAlertView * tempoAlert;
    UIAlertView *beatAlert;
    UIAlertView *sucessAlert;
    UIAlertView* emailAlert;
    UIAlertView* deleteAlert;
    UIAlertView* inAppPurchaseAlert;
    UIAlertView* helpAlert;
    UIActionSheet *changeRegularInstrumentSheet;
    UIActionSheet *changeUserInstrumentSheet;
    UIActionSheet *typeOfInstrumentsSheet;
}
@property (strong, nonatomic) AxonixFullScreenAdViewController *fullScreenAdViewController;
@property (weak, nonatomic) IBOutlet UITextField *beatsTextField;

@property (strong, nonatomic) id name;

@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UITextField *tempoField;
@property  SlidingSegment *instrumentController;
@property FullGrid* fullGrid;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;

-(IBAction)changeTempo;
-(IBAction)replay;
-(IBAction)changeAccedintal:(UISegmentedControl *)sender;
-(IBAction)play:(UIBarButtonItem*)sender;
-(IBAction)loop:(UIBarButtonItem*)sender;
-(IBAction)changeBeat;
-(IBAction)exportMusic:(UIBarButtonItem *) button;
-(IBAction)openEditor:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *topBar;

+(Instrument *)CURRENT_INSTRUMENT;
+(Accidental)CURRENT_ACCIDENTAL;
+(BOOL)LOOPING;
@end

