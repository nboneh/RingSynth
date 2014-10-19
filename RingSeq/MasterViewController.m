
//
//  MasterViewController.m
//  RingSeq
//
//  Created by Nir Boneh on 10/9/14.
//  Copyright (c) 2014 Clouby. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ToastView.h"

@implementation MasterViewController
static const NSString *RINGTONES_LIST_FILE = @"ringtones.dat";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    ringtones = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPath:(id)RINGTONES_LIST_FILE]];
    if(ringtones == nil)
        ringtones = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(enteredBackground:)
                                                 name: @"didEnterBackground"
                                               object: nil];
    
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
    return NO;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    NSString *text = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceCharacterSet]];
    if(text.length == 0)
        return NO;
    NSInteger size = [ringtones count];
    for(int i = 0; i < size; i++){
        NSString *ring = [ringtones objectAtIndex:i];
        if ([text caseInsensitiveCompare:ring] == NSOrderedSame){
            return NO;
        }
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        NSString *newRing = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]];
        
        [ringtones insertObject:newRing atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:newRing];
        if (cell == nil && self.tableView != self.tableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:newRing];
        }
        if(fileToBeDeleted){
            //Copy content to new renamed file
            NSString *copyContent = [NSKeyedUnarchiver unarchiveObjectWithFile: fileToBeDeleted];
            [NSKeyedArchiver archiveRootObject:copyContent toFile:[self getPath:(id) newRing]];
            
        }
        
    }
    if(fileToBeDeleted){
        //Delete the file
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL exists = [fm fileExistsAtPath:fileToBeDeleted];
        if(exists == YES)
            [fm removeItemAtPath:fileToBeDeleted error:nil];
    }
    fileToBeDeleted =nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *ringtone = ringtones[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
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
        return [ringtones count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(tableView==self.searchDisplayController.searchResultsTableView)
        cell.textLabel.text = searchResults[indexPath.row];
    else
        cell.textLabel.text = ringtones[indexPath.row];
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
        NSString *text =[ringtones objectAtIndex:indexPath.row];
        fileToBeDeleted =[self getPath:[ringtones objectAtIndex:indexPath.row]];
        
        [ringtones removeObjectAtIndex:indexPath.row];
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
    searchResults = [ringtones filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(void)enteredBackground:(NSNotification *)notification{
    //Saving ringtones
    [NSKeyedArchiver archiveRootObject:ringtones toFile:[self getPath:(id) RINGTONES_LIST_FILE]];
    
}

- (NSString *) getPath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [path stringByAppendingPathComponent:fileName];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationLandscapeRight;
}

@end
