//
//  AppDelegate.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/10.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Parse
import ParseCrashReporting
import ParseFacebookUtilsV4
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var networkStatus: Reachability.NetworkStatus?
    private var firstLaunch: Bool = true
    
    
    func sharedInstance() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func appDelegate() -> AppDelegate
    {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // 設定Fabric
        Fabric.with([Crashlytics.self])
        
        // 設定Parse
        // ****************************************************************************
        // Parse initialization
        ParseCrashReporting.enable()
        Parse.setApplicationId("HvbrCuCAF3PwHACiplKeghYbeIcpPVFlSvSXmhrQ", clientKey: "NTwqjCdGPQesiN4Enox3ytfgzqWqJT89WshyL0Hx")
        // 設定FacebookUtilsV4
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        // TODO: PFFacebookUtils.initialize()
        // ****************************************************************************
        
        // 追蹤 app open.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        if (PFUser.currentUser() != nil) {
            let defaultACL = PFACL()
            // If you would like all objects to be private by default, remove this line.
            defaultACL.setReadAccess(true, forUser: PFUser.currentUser()!)
            PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        }
        
        if (application.applicationState != UIApplicationState.Background) {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
        }
        
        // Badge歸零
        if application.applicationIconBadgeNumber != 0 {
            application.applicationIconBadgeNumber = 0
            PFInstallation.currentInstallation()!.saveInBackground()
        }
        
        let defaultACL: PFACL = PFACL()
        // Enable public read access by default, with any newly created PFObjects belonging to the current user
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        
        // 設定Theme
        // Set up our app's global UIAppearance
        self.setupAppearance()
        
        // Use Reachability to monitor connectivity
        self.monitorReachability()
        
        self.handlePush(launchOptions)
        
        // Register for Push Notitications （不一定要在這裡實作） iOS9 的做法
        let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return true
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if (application.applicationIconBadgeNumber != 0) {
            application.applicationIconBadgeNumber = 0
        }
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation?.setDeviceTokenFromData(deviceToken)
        currentInstallation?.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code != 3010 { // 3010 is for the iPhone Simulator
            print("Application failed to register for push notifications: \(error)")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName(PAPAppDelegateApplicationDidReceiveRemoteNotification, object: nil, userInfo: userInfo)
//        NotificationCenter.default().post(name: NSNotification.Name(rawValue: PAPAppDelegateApplicationDidReceiveRemoteNotification), object: nil, userInfo: userInfo)
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
        // Track app opens due to a push notification being acknowledged while the app wasn't active.
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        if PFUser.currentUser() != nil {
        // FIXME: Looks so lengthy, any better way?
        }

    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Clear badge and update installation, required for auto-incrementing badges.
        if application.applicationIconBadgeNumber != 0 {
            application.applicationIconBadgeNumber = 0
            PFInstallation.currentInstallation()!.saveInBackground()
        }
        
        // Clears out all notifications from Notification Center.
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        application.applicationIconBadgeNumber = 0
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    
    // MARK:- AppDelegate
    
    func isParseReachable() -> Bool {
        return self.networkStatus != .NotReachable
    }
    
    // 跳出登入畫面
    func presentLoginViewController(animated: Bool = true) {
        //        self.welcomeViewController!.presentLoginViewController(animated)
    }
    
    // 跳出首頁Tabbar頁面
    internal func presentTabBarController() {
        
    }
    
    func logOut() {
        // clear cache
        PAPCache.sharedCache.clear()
        
        // clear NSUserDefaults
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kPAPUserDefaultsCacheFacebookFriendsKey)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // Unsubscribe from push notifications by removing the user association from the current installation.
        PFInstallation.currentInstallation()?.removeObjectForKey(kPAPInstallationUserKey)
        PFInstallation.currentInstallation()!.saveInBackground()
        
        // Clear all caches
        PFQuery.clearAllCachedResults()
        
        // Log out
        PFUser.logOut()
        //        FBSession.setActiveSession(nil)
        _ = FBSDKAccessToken.currentAccessToken().tokenString
        
        // clear out cached data, view controllers, etc
        
        presentLoginViewController()
    }
    
    
    // MARK: - 其他
    
    // Set up appearance parameters to achieve Anypic's custom look and feel
    func setupAppearance() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().tintColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //        UIButton.appearanceWhenContainedInInstancesOfClasses([UINavigationBar.self]).setTitleColor(UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 50.0/255.0, alpha: 1.0), forState: [])
        
        UIBarButtonItem.appearance().setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 50.0/255.0, alpha: 1.0) ], forState: [])
        
        UISearchBar.appearance().tintColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 50.0/255.0, alpha: 1.0)
    }
    
    func monitorReachability() {
        guard let reachability = Reachability(hostname: "api.parse.com") else {
            return
        }
        
        reachability.whenReachable = { (reach: Reachability) in
            self.networkStatus = reach.currentReachabilityStatus
            if self.isParseReachable() && PFUser.currentUser() != nil {
                // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
                // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
            }
        }
        reachability.whenUnreachable = { (reach: Reachability) in
            self.networkStatus = reach.currentReachabilityStatus
        }
        
        _ = reachability.startNotifier()
    }
    
    func handlePush(launchOptions: [NSObject: AnyObject]?) {
        // If the app was launched in response to a push notification, we'll handle the payload here
        guard let remoteNotificationPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject : AnyObject] else { return }
        
        NSNotificationCenter.defaultCenter().postNotificationName(PAPAppDelegateApplicationDidReceiveRemoteNotification, object: nil, userInfo: remoteNotificationPayload)
        
        if PFUser.currentUser() == nil {
            return
        }
        
        // If the push notification payload references a photo, we will attempt to push this view controller into view
        if let photoObjectId = remoteNotificationPayload[kPAPPushPayloadPhotoObjectIdKey] as? String where photoObjectId.characters.count > 0 {
        //            shouldNavigateToPhoto(PFObject(outDataWithObjectId: photoObjectId))
        return
        }
        
        // If the push notification payload references a user, we will attempt to push their profile into view
        guard let fromObjectId = remoteNotificationPayload[kPAPPushPayloadFromUserObjectIdKey] as? String where fromObjectId.characters.count > 0 else { return }
        
        let query: PFQuery? = PFUser.query()
        query!.cachePolicy = PFCachePolicy.CacheElseNetwork
        query!.getObjectInBackgroundWithId(fromObjectId) { (user, error) in
            if error == nil {
//                let homeNavigationController = self.tabBarController!.viewControllers![PAPTabBarControllerViewControllerIndex.HomeTabBarItemIndex.rawValue] as? UINavigationController
//                self.tabBarController!.selectedViewController = homeNavigationController
                
//                let accountViewController = PAPAccountViewController(user: user as! PFUser)
//                print("Presenting account view controller with user: \(user!)")
//                homeNavigationController!.pushViewController(accountViewController, animated: true)
            }
        }
    }
    
    func autoFollowTimerFired(aTimer: NSTimer) {
//                MBProgressHUD.hideHUDForView(navController!.presentedViewController!.view, animated: true)
//                MBProgressHUD.hideHUDForView(homeViewController!.view, animated: true)
//                self.homeViewController!.loadObjects()
    }
    
    func shouldProceedToMainInterface(user: PFUser)-> Bool{
        //        MBProgressHUD.hideHUDForView(navController!.presentedViewController!.view, animated: true)
        self.presentTabBarController()
        
        //        self.navController!.dismissViewControllerAnimated(true, completion: nil)
        return true
    }
    
    func handleActionURL(url: NSURL) -> Bool {
        if url.host == kPAPLaunchURLHostTakePicture {
            if PFUser.currentUser() != nil {
                //                return tabBarController!.shouldPresentPhotoCaptureController()
            }
        } else {
            // FIXME: Is it working?           if ([[url fragment] rangeOfString:@"^pic/[A-Za-z0-9]{10}$" options:NSRegularExpressionSearch].location != NSNotFound) {
            //            if url.fragment!.rangeOfString("^pic/[A-Za-z0-9]{10}$" , options: [.RegularExpressionSearch]) != nil {
            //                let photoObjectId: String = url.fragment!.subString(4, length: 10)
            //                if photoObjectId.length > 0 {
            //                    print("WOOP: %@", photoObjectId)
            //                    shouldNavigateToPhoto(PFObject(outDataWithObjectId: photoObjectId))
            //                    return true
            //                }
            //            }
        }
        
        return false
    }
    
    func autoFollowUsers() {
        firstLaunch = true
        PFCloud.callFunctionInBackground("autoFollowUsers", withParameters: nil) { (object, error) in
            if error != nil {
                print("Error auto following users: \(error)")
            }
            
//            MBProgressHUD.hideHUDForView(self.navController!.presentedViewController!.view, animated:false)
//            self.homeViewController!.loadObjects()
        }
    }

}

