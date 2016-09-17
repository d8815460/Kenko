//
//  StartViewController.swift
//  TweenController
//
//  Created by Dalton Claybrook on 5/26/16.
//
//  Copyright (c) 2016 Dalton Claybrook
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import TweenController
import ParseUI
import MBProgressHUD
import Synchronized
import ParseFacebookUtils


//protocol StartViewControllerDelegate {
//    func userDidLogined()
//}

class StartViewController: UIViewController, TutorialViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var pageControl: UIPageControl!
 
    private var appearanceToken: dispatch_once_t = 0
    private var tweenController: TweenController!
    private var scrollView: UIScrollView!
    private var loginDelegate:StartViewControllerDelegate?
    
    public var presentedLoginViewControllerBool: Bool = false
    private var _facebookResponseCount: Int = 0
    private var _expectedFacebookResponseCount: Int = 0
    private var delegate: PFLogInViewControllerDelegate?
    private var _profilePicData: NSMutableData? = nil
    private var hud: MBProgressHUD?
    
    //MARK: Superclass
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let messangerQuery: PFQuery = PFQuery(className: "match")
        messangerQuery.findObjectsInBackgroundWithBlock { (objects, error) in
            if error != nil {
                print("error = \(error)")
            }
            print("objects = \(objects)")
        }
        
        
        dispatch_once(&appearanceToken) {
            let (tc, scrollView) = TutorialBuilder.buildWithContainerViewController(self)
            self.tweenController = tc
            self.scrollView = scrollView
            scrollView.delegate = self
        }
        
//        if PFUser.currentUser() == nil {
//            presentLoginViewController(true)
//            return
//        }
        
        // Refresh current user with server side data -- checks if user is still valid and so on
        _facebookResponseCount = 0
        PFUser.currentUser()?.fetchInBackgroundWithTarget(self, selector: #selector(StartViewController.refreshCurrentUserCallbackWithResult(_:error:)))
    }
    
    //MARK: Private
    
    // MARK:- PAPLoginViewControllerDelegate
    func logInViewControllerDidLogUserIn(logInViewController: PFLogInViewController) {
        if presentedLoginViewControllerBool {
            presentedLoginViewControllerBool = false
            self.loginDelegate!.userDidLogined()
            self.dismissViewControllerAnimated(true, completion: nil)
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
        
        if (PFUser.currentUser()!.objectForKey(kPAPUserPositiveKey) != nil)  {
            
        } else {
            PFUser.currentUser()!.setObject(0, forKey: kPAPUserPositiveKey)
        }
        
        if (PFUser.currentUser()!.objectForKey(kPAPUserNegativeKey) != nil) {
            
        } else {
            PFUser.currentUser()!.setObject(0, forKey: kPAPUserNegativeKey)
        }
        
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
        if PFUser.currentUser() != nil {
            presentedLoginViewControllerBool = false
        }else{
            presentedLoginViewControllerBool = true
        }
        logInController.dismissViewControllerAnimated(true) {
            self.dismissViewControllerAnimated(true, completion: { 
                
            })
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
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(StartViewController.logInViewControllerDidLogUserIn(_:))) {
                self.delegate!.performSelector(#selector(StartViewController.logInViewControllerDidLogUserIn(_:)), withObject: PFUser.currentUser()!)
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
                        if self.delegate!.respondsToSelector(#selector(StartViewController.logInViewControllerDidLogUserIn(_:))) {
                            self.delegate!.performSelector(#selector(StartViewController.logInViewControllerDidLogUserIn(_:)), withObject: user)
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
    
    
    private func updatePageControl() {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / containerView.frame.width))
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let loginViewController = PFLogInViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = ["public_profile", "user_friends", "email", "user_photos"]
        loginViewController.fields = [PFLogInFields.Facebook,
                                      PFLogInFields.DismissButton]
        loginViewController.logInView?.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLogin")!)
        
        let label = UILabel(frame: CGRectMake(0, 0, 200, 35))
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.center = CGPointMake(160, 154)
        label.font = label.font.fontWithSize(28)
        label.text = "Kenko.Today"
        
        loginViewController.logInView?.logo = nil
        loginViewController.logInView?.addSubview(label)
        
        let signupViewController = PFSignUpViewController()
        signupViewController.delegate = self
        loginViewController.signUpController = signupViewController

        presentViewController(loginViewController, animated: true) { 
            
        }
    }
    
    @IBAction func signupButtonPressed(sender: AnyObject) {
        let signupViewController = PFSignUpViewController()
        signupViewController.delegate = self
        presentViewController(signupViewController, animated: true) {
            
        }
    }
    
}

extension StartViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        tweenController.updateProgress(scrollView.twc_horizontalPageProgress)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updatePageControl()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updatePageControl()
        }
    }
}
