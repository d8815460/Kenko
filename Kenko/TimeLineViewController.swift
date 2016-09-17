//
//  TimeLineViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/10.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import ParseUI
import Synchronized
import MBProgressHUD
import ParseFacebookUtils
import FormatterKit

protocol StartViewControllerDelegate {
    func userDidLogined()
}

class TimeLineViewController: PFQueryTableViewController, StartViewControllerDelegate {
    
    private var timeIntervalFormatter: TTTTimeIntervalFormatter?
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        
        //Use the Parse built-in user class
        self.parseClassName = kPAPPostsClassKey
        
        //This is a custom column in the user class.
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Use the Parse built-in user class
        self.parseClassName = kPAPPostsClassKey
        
        //This is a custom column in the user class.
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 100.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        view.backgroundColor = UIColor.init(red: 94/255.0, green: 89/255.0, blue: 151/255.0, alpha: 1)
        
        self.timeIntervalFormatter = TTTTimeIntervalFormatter()
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            presentLoginViewController(true)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: kPAPPostsClassKey)
        
        query.limit = 1000
        query.includeKey(kPAPPhotoUserKey)
        
        //It's very important to sort the query.  Otherwise you'll end up with unexpected results
        query.orderByDescending("createdAt")
        
        
        query.cachePolicy = PFCachePolicy.CacheThenNetwork
        
        return query
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (self.objects?.count)!
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        
        if ((object?.objectForKey("photo")) != nil) {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCellPhoto",  forIndexPath: indexPath) as! TimelineCell
            
            cell.typeImageView?.image = UIImage(named: "timeline-photo")
            let user:PFUser? = object?.objectForKey(kPAPPhotoUserKey) as? PFUser
            let file:PFFile = (user?.objectForKey(kPAPUserProfilePicMediumKey) as? PFFile)!
            file.getDataInBackgroundWithBlock({ (photo, error) in
                if error == nil && photo != nil {
                    cell.profileImageView?.image = UIImage(data: photo!)
                }
            })
            cell.nameLabel?.text = user?.objectForKey(kPAPUserDisplayNameKey) as? String
            
            let timeInterval: NSTimeInterval = object!.createdAt!.timeIntervalSinceNow
            let timestamp: String = self.timeIntervalFormatter!.stringForTimeInterval(timeInterval)
            cell.dateLabel?.text = timestamp
            
            let photofile:PFFile = (object?.objectForKey("photo") as? PFFile)!
            photofile.getDataInBackgroundWithBlock({ (data, error) in
                cell.photoImageView?.image = UIImage(data: data!)
            })
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("TimelineCell",  forIndexPath: indexPath) as! TimelineCell
            
            cell.typeImageView?.image = UIImage(named: "timeline-chat")!
            let user:PFUser? = object?.objectForKey(kPAPPhotoUserKey) as? PFUser
            let file:PFFile = (user?.objectForKey(kPAPUserProfilePicMediumKey) as? PFFile)!
            file.getDataInBackgroundWithBlock({ (photo, error) in
                if error == nil {
                    cell.profileImageView?.image = UIImage(data: photo!)
                }
            })
            cell.nameLabel?.text = user?.objectForKey(kPAPUserDisplayNameKey) as? String
            cell.postLabel?.text = object?.objectForKey("content") as? String
            let timeInterval: NSTimeInterval = object!.createdAt!.timeIntervalSinceNow
            let timestamp: String = self.timeIntervalFormatter!.stringForTimeInterval(timeInterval)
            cell.dateLabel?.text = timestamp
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("article", sender: self.objects![indexPath.row] as! PFObject)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let sendObject:PFObject = sender as! PFObject
        
        if segue.identifier == "article" {
            let articleView = segue.destinationViewController as! ArticleViewController
            articleView.receiveData = sendObject
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
 

    func presentLoginViewController(animated: Bool) {
//        if presentedLoginViewControllerBool {
//            return
//        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let startViewController = storyboard.instantiateViewControllerWithIdentifier("start")
        presentViewController(startViewController, animated: animated, completion: nil)
    }
    
    func userDidLogined() {
        self.dismissViewControllerAnimated(true) {
            
        }
    }
    
}
