import UIKit
import MBProgressHUD
import ParseFacebookUtilsV4

class PAPLogInViewController: UIViewController, FBSDKLoginButtonDelegate {
    var delegate: PAPLogInViewControllerDelegate?
    var _facebookLoginView: FBSDKLoginButton?
    var hud: MBProgressHUD?

    // MARK:- UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // There is no documentation on how to handle assets with the taller iPhone 5 screen as of 9/13/2012
        if UIScreen.mainScreen().bounds.size.height > 480.0 {
            // for the iPhone 5
            // FIXME: We need 3x picture for iPhone 6
            let color = UIColor(patternImage: UIImage(named: "BackgroundLogin.png")!)
            self.view.backgroundColor = color
        } else {
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLogin.png")!)
        }
        
        //Position of the Facebook button
        var yPosition: CGFloat = 360.0
        if UIScreen.mainScreen().bounds.size.height > 480.0 {
            yPosition = 450.0
        }
        _facebookLoginView = FBSDKLoginButton()
        _facebookLoginView?.readPermissions = ["public_profile", "user_friends", "email", "user_photos"]
        _facebookLoginView!.frame = CGRectMake(36.0, yPosition, 244.0, 44.0)
        _facebookLoginView!.delegate = self
        _facebookLoginView!.tooltipBehavior = FBSDKLoginButtonTooltipBehavior.Disable
        self.view.addSubview(_facebookLoginView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        let orientation: UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        return orientation == UIInterfaceOrientation.Portrait
    }
    
    // FIXME: Just replaced with shouldAutorotate above? The one below is deprecated since ios6
//    override func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool {
//        return toInterfaceOrientation == UIInterfaceOrientation.Portrait
//    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }


    // MARK:- FBLoginViewDelegate

    func loginViewShowingLoggedInUser(loginView: FBSDKLoginButton) {
        self.handleFacebookSession()
    }

    func loginView(loginView: FBSDKLoginButton, handleError error: NSError?) {
        self.handleLogInError(error)
    }

    func handleFacebookSession() {
        if PFUser.currentUser() != nil {
            if self.delegate != nil && self.delegate!.respondsToSelector(#selector(PAPLogInViewControllerDelegate.logInViewControllerDidLogUserIn(_:))) {
                self.delegate!.performSelector(#selector(PAPLogInViewControllerDelegate.logInViewControllerDidLogUserIn(_:)), withObject: PFUser.currentUser()!)
            }
            return
        }
        
        let permissionsArray = ["public_profile", "user_friends", "email", "user_photos"]
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        // Login PFUser using Facebook
        PFFacebookUtils.logInInBackgroundWithPublishPermissions(permissionsArray) { (user, error) in
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
                        if self.delegate!.respondsToSelector(#selector(PAPLogInViewControllerDelegate.logInViewControllerDidLogUserIn(_:))) {
                        self.delegate!.performSelector(#selector(PAPLogInViewControllerDelegate.logInViewControllerDidLogUserIn(_:)), withObject: user)
                        }
                    }
                } else {
                    self.cancelLogIn(error)
                }
            }
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if error != nil {
            print("error\(error.description)")
        }
        else if result.isCancelled
        {
            // Handel cancellations
            print("cancelled")
        }
        else
        {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
//            if result.grantedPermissions.contains("email")
//            {
//                // Do work
//                print("check permissions email")
//            } else if result.grantedPermissions.contains("user_photos") {
//                print("check permissions user_photos")
//            } else if result.grantedPermissions.contains("user_friends") {
//                print("check permissions user_friends")
//            } else if result.grantedPermissions.contains("public_profile") {
//                print("check permissions public_profile")
//            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
//            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged Out")
    }

    // MARK:- ()

    func cancelLogIn(error: NSError?) {
        if error != nil {
            self.handleLogInError(error)
        }
        
        self.hud!.removeFromSuperview()
//        FBSession.activeSession().closeAndClearTokenInformation()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        PFUser.logOut()
        (UIApplication.sharedApplication().delegate as! AppDelegate).presentLoginViewController(false)
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
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
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

}

@objc protocol PAPLogInViewControllerDelegate: NSObjectProtocol {
    func logInViewControllerDidLogUserIn(logInViewController: PAPLogInViewController)
}
