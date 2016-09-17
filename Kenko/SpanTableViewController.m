//
//  SpanTableViewController.m
//  taiwan8
//
//  Created by 駿逸 陳 on 2014/9/12.
//  Copyright (c) 2014年 taiwan8. All rights reserved.
//

#import "SpanTableViewController.h"
#import <Parse/Parse.h>

@interface SpanTableViewController ()

@end

@implementation SpanTableViewController
@synthesize currentUser = _currentUser;
@synthesize taskItem = _taskItem;
@synthesize spanLabel = _spanLabel;
@synthesize delegate;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (!indexPath.row) {
//        NSString *CellIdentifier = @"AccountCell";
//        
//        AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (_taskItem && !_currentUser) {
//            if ([[[_taskItem objectForKey:kTaskOwner_User] allKeys] count] == 0) {
//                PFQuery *queryUser = [PFUser query];
//                [queryUser getObjectInBackgroundWithId:[[_taskItem objectForKey:kTaskOwner_User] objectId] block:^(PFObject *object, NSError *error) {
//                    cell.account = (PFUser *)object;
//                }];
//            }else{
//                cell.account = [_taskItem objectForKey:kTaskOwner_User];
//            }
//        }else{
//            cell.account = _currentUser;
//        }
//        
//        return cell;
//    }
    
    NSString *CellIdentifier;
//    CellIdentifier = @"SpanCell";
    UITableViewCell *cell;
    if (indexPath.row == 4) {
        CellIdentifier = @"attentionCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }else if (indexPath.row == 1){
        CellIdentifier = @"SpanCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (cell.isSelected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = @"I don't like this post.";
        return cell;
    }else if (indexPath.row == 2){
        CellIdentifier = @"SpanCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (cell.isSelected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = @"This is porn article or photo.";
        return cell;
    }else if (indexPath.row == 3){
        CellIdentifier = @"SpanCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (cell.isSelected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = @"This is bloody article or photo.";
        return cell;
    }else{
        CellIdentifier = @"SpanCellTitle";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//        return 176.0f;
//    }else
    if (indexPath.row == 4){
        return 129.0f;
    }else{
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 ) {
        if (cell.selected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _spanLabel = cell.textLabel.text;
            self.saveButton.enabled = YES;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            _spanLabel = nil;
            self.saveButton.enabled = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
        if (cell.selected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _spanLabel = cell.textLabel.text;
            self.saveButton.enabled = YES;
        }else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            _spanLabel = nil;
            self.saveButton.enabled = NO;
        }
    }
    
}

- (void)cellObject:(UITableViewCell *)cell isSelected:(BOOL)isSelected{
    if (isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selected = YES;
        self.saveButton.enabled = YES;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selected = NO;
        self.saveButton.enabled = NO;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveButtonPressed:(id)sender {
    if (_spanLabel.length > 0) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"IMPORTANT" message:@"Malicious prosecution will result in your right to use has been suspended for 24-72 hours, and may in the future be permanently suspended. \n Are you sure you want to spam it?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                           [self.navigationController popViewControllerAnimated:NO];
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                       [self span];
                                   }];
        
        [alertView addAction:cancelAction];
        [alertView addAction:okAction];
        
        [self presentViewController:alertView animated:YES completion:nil];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"IMPORTANT" message:@"Malicious prosecution will result in your right to use has been suspended for 24-72 hours, and may in the future be permanently suspended. \n Are you sure you want to span it?" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"YES", nil];
//        [alertView show];
    }else{
        
    }
}

- (IBAction)detailProfileButtonPressed:(id)sender {
//    [self performSegueWithIdentifier:@"profile" sender:nil];
}

- (IBAction)allRatingButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"allRating" sender:nil];
}

- (IBAction)takeTaskButtonPressed:(id)sender {
}

- (IBAction)postTaskButtonPressed:(id)sender {
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    switch (buttonIndex) {
//        case 0:
//            [self.navigationController popViewControllerAnimated:NO];
//            break;
//        case 1:
//            [self span:alertView];
//            break;
//        default:
//            break;
//    }
//}

- (void)span{
    if (_spanLabel.length > 0) {
        
        //先確認是否已經檢舉過
        PFQuery *checkQuery = [PFQuery queryWithClassName:@"Activity"];
        [checkQuery whereKey:@"type" equalTo:@"spam"];
        [checkQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [checkQuery whereKey:@"post" equalTo:_taskItem];
        [checkQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!error && object.allKeys.count > 0) {
                //我已經檢舉過了
                UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"Repeat Span" message:@"System has been registered for this article report" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                               style:UIAlertActionStyleCancel
                                               handler:^(UIAlertAction *action)
                                               {
                                                   NSLog(@"Cancel action");
                                                   [self.navigationController popViewControllerAnimated:NO];
                                               }];
                [alertView addAction:cancelAction];
                [self presentViewController:alertView animated:YES completion:nil];
            }else{
                PFObject *spanObject = [PFObject objectWithClassName:@"Activity"];
                [spanObject setObject:@"spam" forKey:@"type"];
                [spanObject setObject:[PFUser currentUser] forKey:@"fromUser"];
                [spanObject setObject:_spanLabel forKey:@"comment"];
                [spanObject setObject:_taskItem forKey:@"post"];
                
                PFACL *ACL = [PFACL ACL];
                [ACL setPublicReadAccess:YES];
                [ACL setPublicWriteAccess:YES];
                spanObject.ACL = ACL;
                
                [spanObject saveEventually:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"成功SPAN");
                        
                        if ([_spanLabel isEqualToString:@"這是個價格極不合理的任務"]) {
                            //回到上一層頁面
                            [self.navigationController popViewControllerAnimated:NO];
                            //另外要通知上一層頁面再回到上一層
                            [self.delegate SpanTableViewController:self didSpanSomeOne:[(PFObject *)_taskItem objectForKey:@"user"]];
                        }else{
                            //儲存case isHide = true
                            PFQuery *queryCase = [PFQuery queryWithClassName:@"Posts"];
                            [queryCase whereKey:@"objectId" equalTo:[(PFObject *)_taskItem objectId]];
                            [queryCase getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                                [object setObject:[NSNumber numberWithBool:TRUE] forKey:@"isHide"];
                                
                                PFACL *ACL = [PFACL ACL];
                                [ACL setPublicReadAccess:YES];
                                [ACL setPublicWriteAccess:YES];
                                object.ACL = ACL;
                                
                                [object saveEventually:^(BOOL succeeded, NSError *error) {
                                    //回到上一層頁面
                                    [self.navigationController popViewControllerAnimated:NO];
                                    //另外要通知上一層頁面再回到上一層
                                    [self.delegate SpanTableViewController:self didSpanSomeOne:[(PFObject *)_taskItem objectForKey:@"user"]];
                                }];
                            }];
                        }
                    }
                }];
            }
        }];
    }
}



//目標ViewController要添加一個setDetailItem的方法，用來接收這裡的參數
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ([[segue identifier] isEqualToString:@"profile"]){
//        MyDataTableViewController *controller = [segue destinationViewController];
//        if (_taskItem && !_currentUser) {
//            [controller setCurrentUser:[_taskItem objectForKey:kTaskOwner_User]];
//        }else{
//            [controller setCurrentUser:_currentUser];
//        }
//    }else if ([[segue identifier] isEqualToString:@"allRating"]){
//        RatingListTableViewController *controller = [segue destinationViewController];
//        if (_taskItem && !_currentUser) {
//            [controller setDetailItem:[_taskItem objectForKey:kTaskOwner_User]];
//        }else{
//            [controller setDetailItem:_currentUser];
//        }
//    }
}
@end
