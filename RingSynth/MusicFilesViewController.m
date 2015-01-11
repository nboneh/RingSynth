
//
//  MusicFilesViewController.m
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "MusicFilesViewController.h"
#import "MusicViewController.h"
#import "Assets.h"
#import "Util.h"

@implementation MusicFilesViewController
static NSMutableArray *RINGTONE_LIST;
static const NSString * RING_TONE_LIST_FILE_NAME  =@"ringtones.dat";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(resignActive:)
                                                 name: @"applicationWillResignActive"
                                               object: nil];
    self.navigationController.navigationBar.hidden = NO;
    
    //This will load ringtone list
    [MusicFilesViewController RINGTONE_LIST];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addItem{
        UIAlertView * addAlert = [[UIAlertView alloc] initWithTitle:@"New Ringtone" message:@""   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
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
    NSInteger size = [RINGTONE_LIST count];
    for(int i = 0; i < size; i++){
        NSString *ring = [RINGTONE_LIST objectAtIndex:i];
        if ([text caseInsensitiveCompare:ring] == NSOrderedSame){
            return NO;
        }
    }

    return YES;
    
}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    return [self checkTextField:[alertView textFieldAtIndex:0]];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString *newRing = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
        
        [RINGTONE_LIST insertObject:newRing atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:newRing];
        if (cell == nil && self.tableView != self.tableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:newRing];
        }
        if(fileToBeDeleted){
            //Rename the file
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm moveItemAtPath: fileToBeDeleted toPath:[Util getRingtonePath: newRing] error: nil];
            
            //Also delete the ringtone file if it exists
            NSString* ringPath = [fileToBeDeleted stringByReplacingOccurrencesOfString: @ ".rin" withString: @ ".m4r"];
            [fm moveItemAtPath: ringPath toPath:[Util getPath: [NSString stringWithFormat:@"%@.m4r", newRing]] error: nil];
        }
        
    }
    if(buttonIndex == 0 && fileToBeDeleted){
        //Delete the file
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL exists = [fm fileExistsAtPath:fileToBeDeleted];
        if(exists)
            [fm removeItemAtPath:fileToBeDeleted error:nil];
        
        //Also delete the ringtone file if it exists
        NSString* ringPath = [fileToBeDeleted stringByReplacingOccurrencesOfString: @ ".rin" withString: @ ".m4r"];
        exists = [fm fileExistsAtPath:ringPath];
        if(exists == YES)
            [fm removeItemAtPath:ringPath error:nil];
        
    }
    fileToBeDeleted =nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    performSegueOnce = NO;
    if ([[segue identifier] isEqualToString:@"showMusic"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *ringtone = nil;
        if(self.searchDisplayController.active) {
            ringtone =  searchResults[indexPath.row];
        }
        else{
            ringtone = RINGTONE_LIST[indexPath.row];
        }
        MusicViewController *controller = (MusicViewController *)[segue destinationViewController];
        [controller setName:ringtone];
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
        return [RINGTONE_LIST count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(tableView==self.searchDisplayController.searchResultsTableView)
        cell.textLabel.text = searchResults[indexPath.row];
    else
        cell.textLabel.text = RINGTONE_LIST[indexPath.row];
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
        NSString *text =[RINGTONE_LIST objectAtIndex:indexPath.row];
        fileToBeDeleted =[Util getRingtonePath:[RINGTONE_LIST objectAtIndex:indexPath.row]];
        
        [RINGTONE_LIST removeObjectAtIndex:indexPath.row];
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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self beginswith [c] %@", searchText];
    searchResults = [RINGTONE_LIST filteredArrayUsingPredicate:resultPredicate];
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
    //Saving ringtones
    [MusicFilesViewController SAVE_RINGTONE_LIST];
    
}
-(void) viewWillDisappear:(BOOL)animated
{
    //Saving ringtones list
    [super viewDidDisappear:YES];
    [MusicFilesViewController SAVE_RINGTONE_LIST];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    performSegueOnce = YES;
}


-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    //Saftey method so the segue dosen't happen twice
    return performSegueOnce;
}

+(NSMutableArray *)RINGTONE_LIST{
    if(RINGTONE_LIST != nil)
        return  RINGTONE_LIST;
 
    RINGTONE_LIST = [NSKeyedUnarchiver unarchiveObjectWithFile:[Util getPath:(id)RING_TONE_LIST_FILE_NAME]];
   
    if(RINGTONE_LIST == nil)
        RINGTONE_LIST = [[NSMutableArray alloc] init];
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults] ;
    
    if(![userDefaults boolForKey:@"loadedDefaults"]){
        NSString * name = @"Opening (Default) Mix";
        //Loading defaults
        if(![RINGTONE_LIST containsObject:name]){
            
            NSString *musicPath  =[[NSBundle mainBundle] pathForResource:@"Default" ofType:@""];
            NSData * data = [[NSData alloc] initWithContentsOfFile:musicPath];
            [RINGTONE_LIST addObject:name];
            [data writeToFile:[Util getRingtonePath:name] atomically:YES];
        }
        [userDefaults setBool:YES forKey:@"loadedDefaults"];
        [userDefaults synchronize];
        [MusicFilesViewController SAVE_RINGTONE_LIST];
    }
    return RINGTONE_LIST;

}

+(void)SAVE_RINGTONE_LIST{
    [NSKeyedArchiver archiveRootObject:RINGTONE_LIST toFile:[Util getPath:(id) RING_TONE_LIST_FILE_NAME]];
}
@end
