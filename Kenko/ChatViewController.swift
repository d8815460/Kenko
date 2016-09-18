//
//  ChatViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/10.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import FBSDKMessengerShareKit
import MBProgressHUD

class ChatViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var contentView: UIView!
    
    private var timer: NSTimer!
    private var hud: MBProgressHUD!
    private var applications: Application!
    private var detailViewController: DetailViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.init(red: 33/255.0, green: 128/255.0, blue: 189/255.0, alpha: 1)
        
        
        self.webView.delegate = self
        
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud.mode = MBProgressHUDMode.Indeterminate
        self.hud.labelText = "Checking Messenger Login..."
        
        if let btn = FBSDKMessengerShareButton.rectangularButtonWithStyle(FBSDKMessengerShareButtonStyle.White) {
            self.button = btn
            self.button.frame = CGRectMake(8, self.view.frame.height-120, (self.view.frame.width)-16, 46)
            self.button.addTarget(self, action: #selector(ChatViewController.shareButtonPressed), forControlEvents: .TouchUpInside)
            self.button.hidden = true
            view.addSubview(self.button)
        }
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.detailViewController = storyboard.instantiateViewControllerWithIdentifier("chatDetail") as! DetailViewController
//        let detailViewController = DetailViewController.init()
        
//        detailViewController.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 120)
//        self.contentView = detailViewController.tableView
//        self.contentView.addSubview(detailViewController.tableView)
        
//        button.addTarget(self, action: #selector(ChatViewController.shareButtonPressed), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button)
        
//        UIButton *button = [FBSDKMessengerShareButton rectangularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue];
//        [button addTarget:self action:@selector(_shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:button];
        
        
    }
    
    override func viewDidLayoutSubviews() {
        detailViewController.tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height - 194)
        
        self.contentView.addSubview(self.detailViewController.tableView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        button = FBSDKMessengerShareButton.rectangularButtonWithStyle(FBSDKMessengerShareButtonStyle.White)
        
        let queryUser = PFUser.query()
        queryUser!.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!) { (user, error) in
            if (user!.objectForKey(kPAPUserChatBotIDKey) != nil) {
                self.webView.hidden = true
                self.button.hidden = false
                if PFUser.currentUser()!.objectForKey(kPAPUserChatBotIDKey) == nil {
                    PFUser.currentUser()?.setObject(user!.objectForKey(kPAPUserChatBotIDKey)!, forKey: kPAPUserChatBotIDKey)
                    PFUser.currentUser()!.saveInBackgroundWithBlock { (succeeded, error) in
                        if !succeeded {
                            print("Failed save in background of user, \(error)")
                        } else {
                            print("saved current parse user")
                        }
                    }
                }
                
                
            } else {
                self.webView.hidden = false
                self.button.hidden = true
            }
        }
        
        
        
        if PFUser.currentUser()?.objectForKey(kPAPUserFacebookIDKey) != nil {
            let url = NSURL (string: "http://enigmatic-meadow-46041.herokuapp.com/button/\(PFUser.currentUser()?.objectForKey(kPAPUserFacebookIDKey)! as! String)");
            let requestObj = NSURLRequest(URL: url!);
            self.webView.loadRequest(requestObj);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
//        print("webView did start Load:\(webView.request?.URL?.absoluteString)")
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        print("webView did finish load: \(webView.request?.URL?.absoluteString)")
        let urlString = webView.request?.URL?.absoluteString
        if let hasPrefix = urlString?.hasPrefix("https://www.messenger.com/?refsrc") {
            if hasPrefix {
                self.webView.hidden = true
                self.button.hidden = false
                NSLog("has hasPrefix")
            } else {
                NSLog("no hasPrefix")
            }
        }
        
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
//        print("webview did fail load with error: \(error)")
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("should start load with request \(request.URL?.absoluteString)")
        let urlString = request.URL?.absoluteString
        if let hasPrefix = urlString?.hasPrefix("https://m.facebook.com/plugins/close_popup.php?") {
            if hasPrefix{
                NSLog("prefix")
                self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ChatViewController.checkWebView), userInfo: nil, repeats: false)
                
            }
            else {
                
                NSLog("no hasPrefix")
            }
        }
        else {
            
            NSLog("nil value")
        }
        if let hasPrefix = urlString?.hasPrefix("https://www.facebook.com/v2.6/plugins/send_to_messenger.php") {
            if hasPrefix {
                self.hud.hide(true)
                NSLog("has hasPrefix")
            } else {
                NSLog("no hasPrefix")
            }
        }
        
        return true
    }

    
    func checkWebView() {
        let url = NSURL (string: "http://enigmatic-meadow-46041.herokuapp.com/button/\(PFUser.currentUser()?.objectForKey(kPAPUserFacebookIDKey)! as! String)");
        let requestObj = NSURLRequest(URL: url!);
        self.webView.loadRequest(requestObj);
        self.timer.invalidate()
    }
    
    
    func shareButtonPressed() {
        let fbUrl: NSURL = NSURL(string: "http://m.me/149502088796502")!
        if UIApplication.sharedApplication().canOpenURL(fbUrl) {
            UIApplication.sharedApplication().openURL(fbUrl)
        }
        
        
//        let metadata = "image:pedro"
//        let image = UIImage(named: "AppIcon")
//        
//        let options = FBSDKMessengerShareOptions.init()
//        options.metadata = metadata
//        options.renderAsSticker = true
//        
//        FBSDKMessengerSharer.shareImage(image, withOptions: options)
//        FBSDKMessengerSharer.openMessenger()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
