//
//  ArticleViewController.swift
//  Mega
//
//  Created by Tope Abayomi on 22/11/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import Foundation
import UIKit
import FormatterKit
import Synchronized

class ArticleViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var topImageView : UIImageView!
    @IBOutlet var dateImageView : UIImageView!
    
    @IBOutlet var backbutton : UIButton!
    
    @IBOutlet var profileImageView : UIImageView!
    @IBOutlet var nameLabel : UILabel!
    
    @IBOutlet var articleLabel : UILabel!
    @IBOutlet var likeButton : UIButton!
    
    @IBOutlet var photosCollectionView : UICollectionView!
    @IBOutlet var photosLabel : UILabel!
    @IBOutlet var photosLayout : UICollectionViewFlowLayout!
    @IBOutlet var photosContainer : UIView!
    
    private var timeIntervalFormatter: TTTTimeIntervalFormatter?
    var photos : [String]!
    
    var receiveData: AnyObject!
    
    /// Array of the users that liked the post
    var likerUsers: [PFUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timeIntervalFormatter = TTTTimeIntervalFormatter()
        
        let post:PFObject = receiveData as! PFObject
        
        titleLabel.font = UIFont(name: MegaTheme.fontName, size: 21)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = post[kPAPPostsTitleKey] as? String
        
        dateLabel.font = UIFont(name: MegaTheme.fontName, size: 10)
        dateLabel.textColor = UIColor.whiteColor()
        let timeInterval: NSTimeInterval = post.createdAt!.timeIntervalSinceNow
        let timestamp: String = self.timeIntervalFormatter!.stringForTimeInterval(timeInterval)
        dateLabel?.text = timestamp
        
        dateImageView.image = UIImage(named: "clock")?.imageWithRenderingMode(.AlwaysTemplate)
        dateImageView.tintColor = UIColor.whiteColor()
        
        topImageView.image = UIImage(named: "indonesia")
        
        let user = post[kPAPPostsUserKey] as! PFUser
        nameLabel.font = UIFont(name: MegaTheme.fontName, size: 18)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.text = user[kPAPUserDisplayNameKey] as? String
        
        let file:PFFile = (user.objectForKey(kPAPUserProfilePicMediumKey) as? PFFile)!
        file.getDataInBackgroundWithBlock({ (photo, error) in
            if error == nil {
                self.profileImageView.image = UIImage(data: photo!)
                self.profileImageView.layer.cornerRadius = 18
                self.profileImageView.clipsToBounds = true
            }
        })
        
        
        articleLabel.font = UIFont(name: MegaTheme.fontName, size: 12)
        articleLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        let attributedString = NSMutableAttributedString(string: "\n\n\((post[kPAPPostsContentKey] as? String)!)")
        
        if post[kPAPPostsThumbnailKey] != nil {
            let file = post[kPAPPostsThumbnailKey] as! PFFile
            file.getDataInBackgroundWithBlock({ (data, error) in
                let textAttachment = NSTextAttachment()
                textAttachment.image = UIImage(data: data!)
                let stringwithAttachment = NSAttributedString(attachment: textAttachment)
                
                attributedString.replaceCharactersInRange(NSMakeRange(0, 1), withAttributedString: stringwithAttachment)
                
                self.articleLabel.attributedText = attributedString
            })
        }
        
        
        
        articleLabel.attributedText = attributedString
        
        let likeImage = UIImage(named: "like")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        likeButton.setImage(likeImage, forState: .Normal)
        
        photosLabel.font = UIFont(name: MegaTheme.boldFontName, size: 16)
        photosLabel.textColor = UIColor.blackColor()
        photosLabel.text = "PHOTOS"
        
        photosContainer.backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.backgroundColor = UIColor.clearColor()
        
        photosLayout.itemSize = CGSizeMake(90, 90)
        photosLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        photosLayout.minimumInteritemSpacing = 2
        photosLayout.minimumLineSpacing = 10
        
        photos = ["photos-1", "photos-2", "photos-3"]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let post:PFObject = receiveData as! PFObject
        likerUsers = PAPCache.sharedCache.likersForPhoto(post)
        
        synchronized(self) {
            // check if we can update the cache
            let query: PFQuery = PAPUtility.queryForActivitiesOnPhoto(post, cachePolicy: PFCachePolicy.NetworkOnly)
            query.findObjectsInBackgroundWithBlock { (objects, error) in
                synchronized(self) {
                    
                    if error != nil {
                        return
                    }
                    
                    var likers = [PFUser]()
                    var commenters = [PFUser]()
                    
                    var isLikedByCurrentUser = false
                    
                    for activity in objects as! [PFObject] {
                        if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike && activity.objectForKey(kPAPActivityFromUserKey) != nil {
                            likers.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
                        } else if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeComment && activity.objectForKey(kPAPActivityFromUserKey) != nil {
                            commenters.append(activity.objectForKey(kPAPActivityFromUserKey) as! PFUser)
                        }
                        
                        if (activity.objectForKey(kPAPActivityFromUserKey) as? PFUser)?.objectId == PFUser.currentUser()!.objectId {
                            if (activity.objectForKey(kPAPActivityTypeKey) as! String) == kPAPActivityTypeLike {
                                isLikedByCurrentUser = true
                                let likeImage = UIImage(named: "unlike")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                                self.likeButton.setImage(likeImage, forState: .Normal)
                            }
                        }
                    }
                    
                    PAPCache.sharedCache.setAttributesForPhoto(post, likers: likers, commenters: commenters, likedByCurrentUser: isLikedByCurrentUser)
                    
                    self.setLikeStatus(PAPCache.sharedCache.isPhotoLikedByCurrentUser(post))
                    self.likeButton!.setTitle(PAPCache.sharedCache.likeCountForPhoto(post).description, forState: UIControlState.Normal)
                    
                }
            }
        }
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 200
        }else if indexPath.row == 2{
            let post:PFObject = receiveData as! PFObject
            if post[kPAPPostsThumbnailKey] != nil {
                return heightForView((articleLabel?.text)!, font: articleLabel.font, width: 300) + 250
            } else {
                return heightForView((articleLabel?.text)!, font: articleLabel.font, width: 190) + 150
            }
            
            
        }else if indexPath.row == 3{
            return 0
        }else{
            return 50
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell!
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        let photo = photos[indexPath.row]
        imageView.image = UIImage(named: photo)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = .None
    }
    
    override func viewDidLayoutSubviews() {
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
    }
    
    func backTapped(sender: AnyObject?){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shouldEnableLikeButton(enable: Bool) {
        if enable {
            let unlikeImage = UIImage(named: "unlike")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.likeButton.setImage(unlikeImage, forState: .Normal)
            self.likeButton!.removeTarget(self, action: #selector(ArticleViewController.likeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            let likeImage = UIImage(named: "like")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            self.likeButton.setImage(likeImage, forState: .Normal)
            self.likeButton!.addTarget(self, action: #selector(ArticleViewController.likeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func setLikeStatus(liked: Bool) {
        self.likeButton!.selected = liked
        
        // FIXME: both are just the same???
        if (liked) {
            self.likeButton!.titleEdgeInsets = UIEdgeInsetsMake(-3.0, 0.0, 0.0, 0.0)
        } else {
            self.likeButton!.titleEdgeInsets = UIEdgeInsetsMake(-3.0, 0.0, 0.0, 0.0)
        }
    }
    
    @IBAction func likeButtonPressed(sender: AnyObject) {
        
        let post:PFObject = receiveData as! PFObject
        
        self.shouldEnableLikeButton(false)
        
        let liked: Bool = !self.likeButton.selected
        self.setLikeStatus(liked)
        
//        let originalButtonTitle = self.likeButton.titleLabel!.text
        
//        var likeCount: Int = Int(self.likeButton.titleLabel!.text!)!
//        if (liked) {
//            likeCount += 1
//            PAPCache.sharedCache.incrementLikerCountForPhoto(post)
//        } else {
//            if likeCount > 0 {
//                likeCount -= 1
//            }
//            PAPCache.sharedCache.decrementLikerCountForPhoto(post)
//        }
        
        PAPCache.sharedCache.setPhotoIsLikedByCurrentUser(post, liked: liked)
        
//        self.likeButton.setTitle(String(likeCount), forState: UIControlState.Normal)
        
        if liked {
            PAPUtility.likePhotoInBackground(post, block: { (succeeded, error) in
                // FIXME: nil??? same as the original AnyPic. Dead code?
//                let actualHeaderView: PAPPhotoHeaderView? = self.tableView(self.tableView, viewForHeaderInSection: button.tag) as? PAPPhotoHeaderView
                self.shouldEnableLikeButton(true)
                self.setLikeStatus(succeeded)
                
//                if !succeeded {
//                    self.likeButton!.setTitle(originalButtonTitle, forState: UIControlState.Normal)
//                }
            })
        } else {
            PAPUtility.unlikePhotoInBackground(post, block: { (succeeded, error) in
                // FIXME: nil??? same as the original AnyPic. Dead code?
//                let actualHeaderView: PAPPhotoHeaderView? = self.tableView(self.tableView, viewForHeaderInSection: button.tag) as? PAPPhotoHeaderView
                self.shouldEnableLikeButton(false)
                self.setLikeStatus(!succeeded)
                
//                if !succeeded {
//                    self.likeButton!.setTitle(originalButtonTitle, forState: UIControlState.Normal)
//                }
            })
        }
    }
    
    
    @IBAction func spamButtonPressed(sender: AnyObject) {
        let post:PFObject = receiveData as! PFObject
        self.performSegueWithIdentifier("spam", sender: post)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let sendObject:PFObject = sender as! PFObject
        
        if segue.identifier == "spam" {
            let articleView = segue.destinationViewController as! SpanTableViewController
            articleView.taskItem = sendObject
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
}