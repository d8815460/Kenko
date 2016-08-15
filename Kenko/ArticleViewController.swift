//
//  ArticleViewController.swift
//  Mega
//
//  Created by Tope Abayomi on 22/11/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import Foundation
import UIKit

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
    
    var photos : [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont(name: MegaTheme.fontName, size: 21)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "21 Days in Indonesia"
        
        dateLabel.font = UIFont(name: MegaTheme.fontName, size: 10)
        dateLabel.textColor = UIColor.whiteColor()
        dateLabel.text = "12 mins ago"
        
        dateImageView.image = UIImage(named: "clock")?.imageWithRenderingMode(.AlwaysTemplate)
        dateImageView.tintColor = UIColor.whiteColor()
        
        topImageView.image = UIImage(named: "indonesia")
        
        nameLabel.font = UIFont(name: MegaTheme.fontName, size: 18)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.text = "by Rachel Cristofsson"
        
        profileImageView.image = UIImage(named: "profile-pic-2")
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        
        let backImage = UIImage(named: "back")?.imageWithRenderingMode(.AlwaysTemplate)
        backbutton.setImage(backImage, forState: .Normal)
        backbutton.tintColor = UIColor.whiteColor()
        backbutton.addTarget(self, action: "backTapped:", forControlEvents: .TouchUpInside)
        
        articleLabel.font = UIFont(name: MegaTheme.fontName, size: 12)
        articleLabel.textColor = UIColor(white: 0.45, alpha: 1.0)
        let attributedString = NSMutableAttributedString(string: "\n\nWhile technically more of a condiment, the chili-based sauce known as sambal is a staple at all Indonesian tables. Dishes are not complete unless they have a hearty dollop of the stuff, a combination of chilies, sharp fermented shrimp paste, tangy lime juice, sugar and salt all pounded up with mortar and pestle. So beloved is sambal, some restaurants have made it their main attraction, with options that include young mango, mushroom and durian.\nIndonesia remains a popular destination with travelers to Asia. Agoda.com understands that traveler want to get the best deal. That's why we offer you the best online rates at 4011 hotels nationwide. We have every main region covered, including West Java, Central Java, East Java, with lots of promotions such as early bird offers and last minute deals. Oh and whatever you do, Bali, Jakarta, Bandung are great cities to visit. With our best price guarantee, we are determined to offer you the best hotels at the best prices.")
        
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIImage(named: "hotel-1")
        let stringwithAttachment = NSAttributedString(attachment: textAttachment)
        
        attributedString.replaceCharactersInRange(NSMakeRange(0, 1), withAttributedString: stringwithAttachment)
        
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
            return heightForView((articleLabel?.text)!, font: articleLabel.font, width: 160)
//            return articleLabel.frame.height
        }else if indexPath.row == 3{
            return 200
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