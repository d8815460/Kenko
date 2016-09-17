//
//  SpanTableViewController.h
//  taiwan8
//
//  Created by 駿逸 陳 on 2014/9/12.
//  Copyright (c) 2014年 taiwan8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class SpanTableViewController;

@protocol SpanTableViewControllerDelegate <NSObject>
- (void)SpanTableViewController:(SpanTableViewController *)controller didSpanSomeOne:(PFUser *)beSpanedUser;
@end

@interface SpanTableViewController : UITableViewController <UIAlertViewDelegate>
@property (nonatomic, weak) id <SpanTableViewControllerDelegate> delegate;
@property (nonatomic, retain) PFObject *taskItem;
@property (nonatomic, retain) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) NSString *spanLabel;

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)detailProfileButtonPressed:(id)sender;
- (IBAction)allRatingButtonPressed:(id)sender;
- (IBAction)takeTaskButtonPressed:(id)sender;
- (IBAction)postTaskButtonPressed:(id)sender;
@end
