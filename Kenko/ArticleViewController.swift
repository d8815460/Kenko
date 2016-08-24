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
                return heightForView((articleLabel?.text)!, font: articleLabel.font, width: 190)
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
}