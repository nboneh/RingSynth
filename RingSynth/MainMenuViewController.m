//
//  MainMenuViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 10/29/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "MainMenuViewController.h"
#import "Assets.h"
#import "Instrument.h"
#import "MusicFilesViewController.h"
#import "Util.h"

@implementation MainMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    [self updateApp];
    
    //Not allowed to go back using slide from nested view controllers 
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    [self adjustButton:self.createButton];
    [self adjustButton:self.helpButton];
    [self adjustButton:self.shopButton];
    [self adjustButton:self.makeButton];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        [self.mainTitle setFont:[self.mainTitle.font fontWithSize:70]];
    }

     self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.view  setNeedsDisplay];
    
    
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *controller = [segue destinationViewController];
    controller.navigationItem.backBarButtonItem = self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
}
-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)adjustButton:(UIButton *)button{
   // button.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraintWidth, *constraintHeight;

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
                 [button.titleLabel  setFont:[UIFont systemFontOfSize:30]];
    }
    
     CGSize dimensionAdd = [@"y" sizeWithAttributes:@{NSFontAttributeName:[button titleLabel].font}];
    CGSize textSize = [[button titleLabel].text sizeWithAttributes:@{NSFontAttributeName:[button titleLabel].font}];

    //Increasing size of font if on ipad
    constraintWidth = [NSLayoutConstraint constraintWithItem:button
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0
                                                        constant:(textSize.width + dimensionAdd.width*2)];
        
        
        
    constraintHeight = [NSLayoutConstraint constraintWithItem:button
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:0
                                                         constant:(textSize.height + dimensionAdd.height*.7f)];
        
    
    [button addConstraint:constraintHeight];
    [button addConstraint:constraintWidth];
    [button setBackgroundImage:[UIImage imageNamed:@"buttonbackground"] forState:UIControlStateNormal];
    
}

-(void) updateApp{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults boolForKey:@"updatedApp"])
        return;
   //All ringtone files will now have .rin extension
    NSArray * ringtones = [MusicFilesViewController RINGTONE_LIST];
    NSFileManager *fm = [NSFileManager defaultManager];
    for(NSString * ringtone in ringtones){
        NSString * path = [Util getPath:ringtone];
        if([fm fileExistsAtPath:path] ){
            NSString *newPath = [Util getRingtonePath:ringtone];
            NSString *copyContent = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
            [NSKeyedArchiver archiveRootObject:copyContent toFile:newPath];
            [fm removeItemAtPath:path error:nil];
            
        }
    }
    
    [userDefaults setBool:YES forKey:@"updatedApp"];
    [userDefaults synchronize];
}
@end
