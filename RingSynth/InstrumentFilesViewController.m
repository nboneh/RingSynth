//
//  InstrumentsViewController.m
//  RingSynth
//
//  Created by Nir Boneh on 12/27/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "InstrumentFilesViewController.h"
#import "Util.h"
#import "Assets.h"
#import "NoteDescription.h"
@interface InstrumentFilesViewController ()

@end

@implementation InstrumentFilesViewController

static NSMutableArray *INSTRUMENT_LIST;
static const NSString * INSTRUMENT_LIST_FILE_NAME  =@"instruments.dat";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(resignActive:)
                                                 name: @"applicationWillResignActive"
                                               object: nil];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    //This will load instrument list
    [InstrumentFilesViewController INSTRUMENT_LIST];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addItem{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"com.clouby.ios.RingSynth.UnlimitedUserPack"]  && INSTRUMENT_LIST.count >=2){
        inAppPurchaseAlert =[[UIAlertView alloc] initWithTitle:@"Purchase of Unlimited User Instruments Required!" message:@"Would you like to visit the shop?"   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [inAppPurchaseAlert show];
        return;
    }
    
    
    UIAlertView * addAlert = [[UIAlertView alloc] initWithTitle:@"New Instrument" message:@""   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[addAlert textFieldAtIndex:0] setDelegate:self];
    [addAlert show];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [self checkTextField:textField];
}
-(BOOL)checkTextField:(UITextField *) textField{
    NSString *text = [textField.text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    if(text.length == 0  || text.length >= 40)
        return NO;
    NSInteger size = [INSTRUMENT_LIST count];
    for(int i = 0; i < size; i++){
        NSString *inst = [[INSTRUMENT_LIST objectAtIndex:i] objectForKey:@"name"];
        if ([text caseInsensitiveCompare:inst] == NSOrderedSame){
            return NO;
        }
    }
    
    return YES;
    
}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    if(alertView == inAppPurchaseAlert)
        return YES;
    return [self checkTextField:[alertView textFieldAtIndex:0]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView == inAppPurchaseAlert){
        if(buttonIndex == 1){
            
            [self performSegueWithIdentifier: @"pushShopFromInstruments" sender: self];
        }
        return;
    }
    
    if(buttonIndex == 1){
        NSString *newInstName = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
        NSMutableDictionary * newInst = nil;
        if(fileToBeDeleted){
            newInst = fileToBeDeleted;
            [newInst setObject: newInstName forKey:@"name"];
        } else{
            newInst = [[NSMutableDictionary alloc] init];
            [newInst setValue:newInstName forKey:@"name"];
            [newInst setValue:[UIColor redColor] forKey:@"color"];
            [newInst setValue: @"Deleted Instrument" forKey:@"imageName"];
            [newInst setValue:[[NoteDescription alloc] initWithOctave:5 andChar:'c'] forKey:@"baseNote"];
            [newInst setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
        }
        
        [INSTRUMENT_LIST insertObject:newInst atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:newInstName];
        if (cell == nil && self.tableView != self.tableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:newInstName];
        }
        
    }
    
    if(buttonIndex == 0 && fileToBeDeleted){
        //Also delete the wav file
        NSString * wavFilePath = [Util getPath:[NSString stringWithFormat:@"%@.wav", [fileToBeDeleted objectForKey:@"uuid"]]];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL exists = [fm fileExistsAtPath:wavFilePath];
        if(exists)
            [fm removeItemAtPath:wavFilePath error:nil];
                    
    }
    fileToBeDeleted =nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    performSegueOnce = NO;
    if ([[segue identifier] isEqualToString:@"showInstrument"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *instrument = nil;
        if(self.searchDisplayController.active) {
            instrument =  searchResults[indexPath.row];
        }
        else {
               instrument = INSTRUMENT_LIST[indexPath.row];
        }
        InstrumentViewController *controller = (InstrumentViewController *)[segue destinationViewController];
        [controller setInstrumentData:instrument];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [INSTRUMENT_LIST count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *instrumentData = nil;
    if(tableView==self.searchDisplayController.searchResultsTableView)
        instrumentData = searchResults[indexPath.row];
    else
        instrumentData = INSTRUMENT_LIST[indexPath.row];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
    
    
    cell.textLabel.text = [instrumentData objectForKey:@"name"];
    cell.contentView.tintColor = [instrumentData objectForKey:@"color"];

    NSString * imageName = [instrumentData objectForKey:@"imageName"];
 
    cell.image =[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Edit";
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertView * editAlert = [[UIAlertView alloc] initWithTitle:@"Edit" message:@""   delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Rename", nil];
        editAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        NSString *text =[[INSTRUMENT_LIST objectAtIndex:indexPath.row] objectForKey:@"name"];
        fileToBeDeleted =[INSTRUMENT_LIST objectAtIndex:indexPath.row];
        
        [INSTRUMENT_LIST removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[editAlert textFieldAtIndex:0] setText: text];
        [[editAlert textFieldAtIndex:0] setDelegate:self];
        [editAlert show];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(name beginswith [c] %@)" , searchText];
    searchResults = [INSTRUMENT_LIST filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)resignActive:(NSNotification *)notification{
    //Saving instruments
    [InstrumentFilesViewController SAVE_INSTRUMENT_LIST];
    
}
-(void) viewWillDisappear:(BOOL)animated
{
    //Saving instruments list
    [super viewDidDisappear:YES];
    [InstrumentFilesViewController SAVE_INSTRUMENT_LIST];
    [Assets UPDATE_USER_INSTRUMENTS];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    performSegueOnce = YES;
    [self.tableView reloadData];
}


-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //Saftey method so the segue dosen't happen twice
    return performSegueOnce;
}

+(NSMutableArray *)INSTRUMENT_LIST{
    if(INSTRUMENT_LIST != nil)
        return  INSTRUMENT_LIST;
    
    INSTRUMENT_LIST = [NSKeyedUnarchiver unarchiveObjectWithFile:[Util getPath:(id)INSTRUMENT_LIST_FILE_NAME]];
    
    if(INSTRUMENT_LIST == nil)
        INSTRUMENT_LIST = [[NSMutableArray alloc] init];
    
    return INSTRUMENT_LIST;
    
}

+(void)SAVE_INSTRUMENT_LIST{
    [NSKeyedArchiver archiveRootObject:INSTRUMENT_LIST toFile:[Util getPath:(id) INSTRUMENT_LIST_FILE_NAME]];
}
@end
