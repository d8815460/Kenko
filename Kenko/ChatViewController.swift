//
//  ChatViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/10.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import FBSDKMessengerShareKit

class ChatViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.init(red: 33/255.0, green: 128/255.0, blue: 189/255.0, alpha: 1)
        
        
        let button2 = FBSDKMessengerShareButton.rectangularButtonWithStyle(FBSDKMessengerShareButtonStyle.White)
        button2.frame = CGRectMake(8, self.view.frame.height/2, (self.view.frame.width)-16, 46)
        button2.addTarget(self, action: #selector(ChatViewController.shareButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(button2)
        
//        button.addTarget(self, action: #selector(ChatViewController.shareButtonPressed), forControlEvents: .TouchUpInside)
//        self.view.addSubview(button)
        
//        UIButton *button = [FBSDKMessengerShareButton rectangularButtonWithStyle:FBSDKMessengerShareButtonStyleBlue];
//        [button addTarget:self action:@selector(_shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:button];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func shareButtonPressed() {
        let options = FBSDKMessengerShareOptions.init()
        options.renderAsSticker = true
        
        FBSDKMessengerSharer.shareImage(UIImage(named: "AppIcon"), withOptions: options)
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
