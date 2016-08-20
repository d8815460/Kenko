//
//  HowMuchMoneyYouWantViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/20.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import ParseUI
import MBProgressHUD
import Synchronized
import ParseFacebookUtils

class HowMuchMoneyYouWantViewController: UIViewController, UITextFieldDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UIScrollViewDelegate  {

    @IBOutlet weak var moneyTextField: UITextField!
    private var _presentedLoginViewController: Bool = false
    private var _facebookResponseCount: Int = 0
    private var _expectedFacebookResponseCount: Int = 0
    private var delegate: PFLogInViewControllerDelegate?
    private var _profilePicData: NSMutableData? = nil
    private var hud: MBProgressHUD?
    var askSend: Bool = false
    @IBOutlet weak var totalMoneyLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        moneyTextField.delegate = self
        moneyTextField.becomeFirstResponder()
        
        self.scrollView.delegate = self
        self.scrollView.scrollEnabled = true
        
        let appear = {
            () -> Void in
            self.top.constant = 0
            self.viewDidAppear(true)
        }
        
        self.scrollView.addPullToRefreshWithActionHandler {
            appear()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            presentLoginViewController(false)
            return
        }
        
        if askSend == true {
            self.performSegueWithIdentifier("711", sender: nil)
        }
        // Refresh current user with server side data -- checks if user is still valid and so on
        _facebookResponseCount = 0
        if (PFUser.currentUser()![kPAPUserProfilePicMediumKey] == nil) {
            PFUser.currentUser()?.fetchInBackgroundWithTarget(self, selector: #selector(TimeLineViewController.refreshCurrentUserCallbackWithResult(_:error:)))
        }
        
        
        let queryMoney = PFQuery.init(className: kPAPMoneyClassKey)
        queryMoney.getFirstObjectInBackgroundWithBlock { (money, error) in
            if error == nil {
                self.totalMoneyLabel.text = "\(money![kPAPMoneyCountKey]!)"
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func presentLoginViewController(animated: Bool) {
        if _presentedLoginViewController {
            return
        }
        
        _presentedLoginViewController = true
        
        let loginViewController = PFLogInViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = ["public_profile", "user_friends", "email", "user_photos"]
        loginViewController.fields = [PFLogInFields.Facebook,
                                      PFLogInFields.DismissButton]
        presentViewController(loginViewController, animated: animated, completion: nil)
    }
    
    // MARK:- PAPLoginViewControllerDelegate
    func logInViewControllerDidLogUserIn(logInViewController: PFLogInViewController) {
        if _presentedLoginViewController {
            _presentedLoginViewController = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // 數值不得超過1000元
        if string == " " {
            return false
        }
        
        let userEnteredString = textField.text
        
        let newString = (userEnteredString! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        
        print(newString.intValue)

        if newString.intValue > 1000 {
            moneyTextField.text = "1000"
            return false
        }
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        
        print("Did End Editing")
        if textField.text?.characters.count > 0 {
            self.performSegueWithIdentifier("commit", sender: textField)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        
        if segue.identifier == "commit" {
            let whyNeed = segue.destinationViewController as! WhyViewController
            let sendObject:UITextField?
            if sender != nil{
                sendObject = sender as? UITextField
                whyNeed.receiveData = sendObject!.text!
            }
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        } else if segue.identifier == "711" {
            let whyNeed = segue.destinationViewController as! SevenViewController
            whyNeed.receiveData = PFUser.currentUser()![kPAPUserLocationKey]
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    
    
    // MARK:- ()
    
    func processedFacebookResponse() {
        // Once we handled all necessary facebook batch responses, save everything necessary and continue
        synchronized(self) {
            _facebookResponseCount += 1;
            if (_facebookResponseCount != _expectedFacebookResponseCount) {
                return
            }
        }
        _facebookResponseCount = 0;
        print("done processing all Facebook requests")
        
        PFUser.currentUser()!.saveInBackgroundWithBlock { (succeeded, error) in
            if !succeeded {
                print("Failed save in background of user, \(error)")
            } else {
                print("saved current parse user")
            }
        }
    }
    
    
    // PFLoginViewDelegate
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        logInController.dismissViewControllerAnimated(true) {
            
        }
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        self.handleLogInError(error)
    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        return true
    }
    
    func handleFacebookSession() {
        if PFUser.currentUser() != nil {
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(TimeLineViewController.logInViewControllerDidLogUserIn(_:))) {
                self.delegate!.performSelector(#selector(TimeLineViewController.logInViewControllerDidLogUserIn(_:)), withObject: PFUser.currentUser()!)
            }
            return
        }
        
        let permissionsArray = ["public_profile", "user_friends", "email"]
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Login PFUser using Facebook
        PFFacebookUtils.logInWithPermissions(permissionsArray) { (user, error) in
            if user == nil {
                var errorMessage: String = ""
                if error == nil {
                    print("Uh oh. The user cancelled the Facebook login.")
                    errorMessage = NSLocalizedString("Uh oh. The user cancelled the Facebook login.", comment: "")
                } else {
                    print("Uh oh. An error occurred: %@", error)
                    errorMessage = error!.localizedDescription
                }
                let alertController = UIAlertController(title: NSLocalizedString("Log In Error", comment: ""), message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(alertAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                if user!.isNew {
                    print("User with facebook signed up and logged in!")
                } else {
                    print("User with facebook logged in!")
                }
                
                if error == nil {
                    self.hud!.removeFromSuperview()
                    if self.delegate != nil {
                        if self.delegate!.respondsToSelector(#selector(TimeLineViewController.logInViewControllerDidLogUserIn(_:))) {
                            self.delegate!.performSelector(#selector(TimeLineViewController.logInViewControllerDidLogUserIn(_:)), withObject: user)
                        }
                    }
                } else {
                    self.cancelLogIn(error)
                }
            }
        }
    }
    
    func handleLogInError(error: NSError?) {
        if error != nil {
            let reason = error!.userInfo["com.facebook.sdk:ErrorLoginFailedReason"] as? String
            print("Error: \(reason)")
            let title: String = NSLocalizedString("Login Error", comment: "Login error title in PAPLogInViewController")
            let message: String = NSLocalizedString("Something went wrong. Please try again.", comment: "Login error message in PAPLogInViewController")
            
            if reason == "com.facebook.sdk:UserLoginCancelled" {
                return
            }
            
            
            if error!.code == PFErrorCode.ErrorFacebookInvalidSession.rawValue {
                print("Invalid session, logging out.")
                (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
                return
            }
            
            if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                let ok = NSLocalizedString("OK", comment: "OK")
                let title = NSLocalizedString("Offline Error", comment: "Offline Error")
                let message = NSLocalizedString("Something went wrong. Please try again.", comment: "Offline message")
                let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: ok, style: .Default, handler: nil)
                
                // Add Actions
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            let ok = NSLocalizedString("OK", comment: "OK")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: ok, style: .Default, handler: nil)
            
            // Add Actions
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func cancelLogIn(error: NSError?) {
        if error != nil {
            self.handleLogInError(error)
        }
        
        self.hud!.removeFromSuperview()
        FBSession.activeSession().closeAndClearTokenInformation()
        PFUser.logOut()
        (UIApplication.sharedApplication().delegate as! AppDelegate).presentLoginViewController(false)
    }
    
    func refreshCurrentUserCallbackWithResult(refreshedObject: PFObject, error: NSError?) {
        // This fetches the most recent data from FB, and syncs up all data with the server including profile pic and friends list from FB.
        
        // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
        if error != nil && error!.code == PFErrorCode.ErrorObjectNotFound.rawValue {
            print("User does not exist.")
            (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
            return
        }
        
        let session: FBSession = PFFacebookUtils.session()!
        if !session.isOpen {
            print("FB Session does not exist, logout")
            (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
            return
        }
        
        if session.accessTokenData.userID == nil {
            print("userID on FB Session does not exist, logout")
            (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
            return
        }
        
        guard let currentParseUser: PFUser = PFUser.currentUser() else {
            print("Current Parse user does not exist, logout")
            (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
            return
        }
        
        let facebookId = currentParseUser.objectForKey(kPAPUserFacebookIDKey) as? String
        if facebookId == nil || facebookId!.characters.count == 0 {
            // set the parse user's FBID
            currentParseUser.setObject(session.accessTokenData.userID, forKey: kPAPUserFacebookIDKey)
        }
        
        if PAPUtility.userHasValidFacebookData(currentParseUser) == false {
            print("User does not have valid facebook ID. PFUser's FBID: \(currentParseUser.objectForKey(kPAPUserFacebookIDKey)), FBSessions FBID: \(session.accessTokenData.userID). logout")
            (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
            return
        }
        
        // Finished checking for invalid stuff
        // Refresh FB Session (When we link up the FB access token with the parse user, information other than the access token string is dropped
        // By going through a refresh, we populate useful parameters on FBAccessTokenData such as permissions.
        PFFacebookUtils.session()!.refreshPermissionsWithCompletionHandler { (session, error) in
            if (error != nil) {
                print("Failed refresh of FB Session, logging out: \(error)")
                (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
                return
            }
            // refreshed
            print("refreshed permissions: \(session)")
            
            
            self._expectedFacebookResponseCount = 0
            let permissions: NSArray = session.accessTokenData.permissions
            // FIXME: How to use "contains" in Swift Array? Replace the NSArray with Swift array
            if permissions.containsObject("public_profile") {
                // Logged in with FB
                // Create batch request for all the stuff
                let connection = FBRequestConnection()
                self._expectedFacebookResponseCount += 1
                connection.addRequest(FBRequest.requestForMe(), completionHandler: { (connection, result, error) in
                    if error != nil {
                        // Failed to fetch me data.. logout to be safe
                        print("couldn't fetch facebook /me data: \(error), logout")
                        (UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
                        return
                    }
                    
                    if let facebookName = result["name"] as? String where facebookName.characters.count > 0 {
                        currentParseUser.setObject(facebookName, forKey: kPAPUserDisplayNameKey)
                    }
                    
                    self.processedFacebookResponse()
                })
                
                // profile pic request
                self._expectedFacebookResponseCount += 1
                connection.addRequest(FBRequest(graphPath: "me", parameters: ["fields": "picture.width(500).height(500)"], HTTPMethod: "GET"), completionHandler: { (connection, result, error) in
                    if error == nil {
                        // result is a dictionary with the user's Facebook data
                        // FIXME: Really need to be this ugly???
                        //                        let userData = result as? [String : [String : [String : String]]]
                        //                        let profilePictureURL = NSURL(string: userData!["picture"]!["data"]!["url"]!)
                        //                        // Now add the data to the UI elements
                        //                        let profilePictureURLRequest: NSURLRequest = NSURLRequest(URL: profilePictureURL!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0) // Facebook profile picture cache policy: Expires in 2 weeks
                        //                        NSURLConnection(request: profilePictureURLRequest, delegate: self)
                        if let userData = result as? [NSObject: AnyObject] {
                            if let picture = userData["picture"] as? [NSObject: AnyObject] {
                                if let data = picture["data"] as? [NSObject: AnyObject] {
                                    if let profilePictureURL = data["url"] as? String {
                                        // Now add the data to the UI elements
                                        let profilePictureURLRequest: NSURLRequest = NSURLRequest(URL: NSURL(string: profilePictureURL)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 10.0) // Facebook profile picture cache policy: Expires in 2 weeks
                                        NSURLConnection(request: profilePictureURLRequest, delegate: self)
                                    }
                                }
                            }
                            
                        }
                    } else {
                        print("Error getting profile pic url, setting as default avatar: \(error)")
                        let profilePictureData: NSData = UIImagePNGRepresentation(UIImage(named: "AvatarPlaceholder.png")!)!
                        PAPUtility.processFacebookProfilePictureData(profilePictureData)
                    }
                    self.processedFacebookResponse()
                })
                if permissions.containsObject("user_friends") {
                    // Fetch FB Friends + me
                    self._expectedFacebookResponseCount += 1
                    connection.addRequest(FBRequest.requestForMyFriends(), completionHandler: { (connection, result, error) in
                        print("processing Facebook friends")
                        if error != nil {
                            // just clear the FB friend cache
                            PAPCache.sharedCache.clear()
                        } else {
                            let data = result.objectForKey("data") as? NSArray
                            let facebookIds: NSMutableArray = NSMutableArray(capacity: data!.count)
                            for friendData in data! {
                                if let facebookId = friendData["id"] {
                                    facebookIds.addObject(facebookId!)
                                }
                            }
                            // cache friend data
                            PAPCache.sharedCache.setFacebookFriends(facebookIds)
                            
                            if currentParseUser.objectForKey(kPAPUserFacebookFriendsKey) != nil {
                                currentParseUser.removeObjectForKey(kPAPUserFacebookFriendsKey)
                            }
                            if currentParseUser.objectForKey(kPAPUserAlreadyAutoFollowedFacebookFriendsKey) != nil {
                                (UIApplication.sharedApplication().delegate as! AppDelegate).autoFollowUsers()
                            }
                        }
                        self.processedFacebookResponse()
                    })
                }
                connection.start()
            } else {
                let profilePictureData: NSData = UIImagePNGRepresentation(UIImage(named: "AvatarPlaceholder.png")!)!
                PAPUtility.processFacebookProfilePictureData(profilePictureData)
                
                PAPCache.sharedCache.clear()
                currentParseUser.setObject("Someone", forKey: kPAPUserDisplayNameKey)
                self._expectedFacebookResponseCount += 1
                self.processedFacebookResponse()
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        self.scrollView.scrollEnabled = true
        self.scrollView.triggerPullToRefresh()
//        let appear = {
//            () -> Void in
//            self.top.constant = 0
//            self.viewDidAppear(true)
//        }
//        
//        self.scrollView.addPullToRefreshWithActionHandler {
//            appear()
//        }
    }
    
    
    // MARK:- NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        _profilePicData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        _profilePicData!.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        PAPUtility.processFacebookProfilePictureData(_profilePicData!)
    }
    
    // MARK:- NSURLConnectionDelegate
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print("Connection error downloading profile pic data: \(error)")
    }
}
