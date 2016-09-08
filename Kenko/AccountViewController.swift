//
//  AccountViewController.swift
//  Mega
//
//  Created by Tope Abayomi on 21/11/2014.
//  Copyright (c) 2014 App Design Vault. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController : UITableViewController, UITextFieldDelegate {
    
    @IBOutlet var profileImageView  : UIImageView!
    @IBOutlet var editBgButton      : UIButton!
    @IBOutlet var editAvatarButton  : UIButton!
    
    @IBOutlet var bgImageView : UIImageView!
    @IBOutlet var profileContainer : UIView!
//    @IBOutlet var doneButton : UIButton!
    
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var locationLabel : UILabel!
    @IBOutlet var locationTextField : UITextField!
    @IBOutlet var emailLabel : UILabel!
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordLabel : UILabel!
    @IBOutlet var passwordTextField : UITextField!
    
    @IBOutlet var pushLabel : UILabel!
    @IBOutlet var pushSwitch : UISwitch!
    @IBOutlet var facebookLabel : UILabel!
    @IBOutlet var facebookImageView : UIImageView!
    @IBOutlet var facebookButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = UIColor(white: 0.92, alpha: 1.0)
        
        
        profileImageView.layer.cornerRadius = 35
        profileImageView.clipsToBounds = true
        
        themeButtonWithText(editAvatarButton, text: "EDIT AVATAR")
        themeButtonWithText(editBgButton, text: "EDIT BACKGROUND")
        
        themeLabelWithText(nameLabel, text: "NAME")
        
        themeTextFieldWithText(nameTextField, text: (PFUser.currentUser()?.objectForKey(kPAPUserDisplayNameKey) as? String)!)
        
        
        themeLabelWithText(pushLabel, text: "PUSH NOTIFICATIONS")
        themeLabelWithText(facebookLabel, text: "LOGGED IN WITH FACEBOOK")
        
        themeButtonWithText(facebookButton, text: "LOGOUT")
        facebookButton.tintColor = UIColor(red: 0.19, green: 0.38, blue: 0.73, alpha: 1.0)
        
        facebookImageView.image = UIImage(named: "fb")
        
        addBlurView()
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 150
        }else if indexPath.row == 5{
            return 15
        }else{
            return 44
        }
    }

    
    func themeButtonWithText(button: UIButton, text:String){
        let background = UIImage(named: "border-button")?.resizableImageWithCapInsets(UIEdgeInsetsMake(10, 10, 10, 10))
        let backgroundTemplate = background!.imageWithRenderingMode(.AlwaysTemplate)
        
        button.setBackgroundImage(backgroundTemplate, forState: .Normal)
        button.setTitle(text, forState: .Normal)
        button.titleLabel?.font = UIFont(name: MegaTheme.fontName, size: 11)
        button.tintColor = UIColor.whiteColor()
    }
    
    func themeTextFieldWithText(textField:UITextField, text: String){
        let largeFontSize : CGFloat = 17
        textField.font = UIFont(name: MegaTheme.lighterFontName, size: largeFontSize)
        textField.textColor = MegaTheme.darkColor
        textField.text = text
        textField.delegate = self
    }
    
    func themeLabelWithText(label: UILabel, text: String){
        let fontSize : CGFloat = 10
        label.font = UIFont(name: MegaTheme.boldFontName, size: fontSize)
        label.textColor = MegaTheme.darkColor
        label.text = text
    }
    
    func addBlurView(){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRectMake(0, 0, 600, 100)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        profileContainer.insertSubview(blurView, aboveSubview: bgImageView)
        
        let topConstraint = NSLayoutConstraint(item: profileContainer, attribute: .Top, relatedBy: .Equal, toItem: blurView, attribute: .Top, multiplier: 1.0, constant: 0.0)
        
        let bottomConstraint = NSLayoutConstraint(item: profileContainer, attribute: .Bottom, relatedBy: .Equal, toItem: blurView, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        
        let leftConstraint = NSLayoutConstraint(item: profileContainer, attribute: .Left, relatedBy: .Equal, toItem: blurView, attribute: .Left, multiplier: 1.0, constant: 0.0)
        
        let rightConstraint = NSLayoutConstraint(item: profileContainer, attribute: .Right, relatedBy: .Equal, toItem: blurView, attribute: .Right, multiplier: 1.0, constant: 0.0)
        
        self.profileContainer.addConstraints([topConstraint, rightConstraint, leftConstraint, bottomConstraint])
    }
    
    @IBAction func doneTapped(sender: AnyObject?){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (user, error) in
            print("user=\(user)")
        })
        
        self.profileImageView.image = UIImage(named: "profile-pic-2")
        let file:PFFile = (PFUser.currentUser()?.objectForKey(kPAPUserProfilePicMediumKey) as? PFFile)!
        file.getDataInBackgroundWithBlock({ (photo, error) in
            if error == nil {
                self.profileImageView.image = UIImage(data: photo!)
            }
        })
        bgImageView.image = UIImage(named: "profile-bg")
        
        themeLabelWithText(locationLabel, text: "EMAIL")
        if PFUser.currentUser()?.objectForKey(kPAPUserEmailKey) != nil {
            themeTextFieldWithText(locationTextField, text: (PFUser.currentUser()?.objectForKey(kPAPUserEmailKey) as? String)!)
        } else {
            themeTextFieldWithText(locationTextField, text: "None")
        }
        
        if PFUser.currentUser()?.objectForKey(kPAPUserPositiveKey) != nil {
            let positive = NSString(format: "%.2f", (PFUser.currentUser()?.objectForKey(kPAPUserPositiveKey) as! Double)*100)
            themeLabelWithText(emailLabel, text: "POSITIVE")
            themeTextFieldWithText(emailTextField, text: "\(positive.doubleValue)%")
        } else {
            themeTextFieldWithText(emailTextField, text: "0%")
        }
        
        
        if PFUser.currentUser()?.objectForKey(kPAPUserNegativeKey) != nil {
            let negative = NSString(format: "%.2f", (PFUser.currentUser()?.objectForKey(kPAPUserNegativeKey) as! Double)*100)
            themeLabelWithText(passwordLabel, text: "NEGATIVE")
            themeTextFieldWithText(passwordTextField, text: "\(negative.doubleValue)%")
        } else {
            themeTextFieldWithText(passwordTextField, text: "0%")
        }
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.deregisterFromKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications ()-> Void   {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AccountViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications () -> Void {
        let center:  NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size
        let insets: UIEdgeInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardSize!.height, 0)
        
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + keyboardSize!.height)
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size
        let insets: UIEdgeInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, keyboardSize!.height, 0)
        
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
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
    @IBAction func facebookbuttonPressed(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
    }
}
