//
//  WriteDetailViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/15.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit

class WriteDetailViewController: UIViewController, UITextViewDelegate {

    var _detailItem:AnyObject?
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    func setDetailItem(detailItem:AnyObject) {
        _detailItem = detailItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if postObject != nil {
            if (postObject!.objectForKey(kPAPPostsContentKey) != nil) {
                textView.text = postObject!.objectForKey(kPAPPostsContentKey) as! String
                textLabel.hidden = true
            } else {
                textLabel.hidden = false
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.text.characters.count > 0 {
            textLabel.hidden = true
        } else {
            textLabel.hidden = false
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.characters.count > 0 {
            if postObject == nil {
                postObject = PFObject.init(className: kPAPPostsClassKey)
            }
            postObject![kPAPPostsContentKey]  = textView.text
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
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
