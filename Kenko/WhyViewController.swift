//
//  WhyViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/20.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import MBProgressHUD

class WhyViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var hud:MBProgressHUD?
    var receiveData: AnyObject!
    var location: PFGeoPoint = PFGeoPoint(latitude: 0.0, longitude: 0.0)
    let manager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("money = \(receiveData)")
        
        textView.delegate = self
        textView.becomeFirstResponder()
        manager.delegate = self
        manager.requestLocation()
        
//        Location.getLocation(withAccuracy: .Block, onSuccess: { (foundLocation) in
//            // Your desidered location is here
//            print("foundLocation = \(foundLocation)")
//            
//            }) { (lastValidLocation, error) in
//                // something bad has occurred
//                // - error contains the error occurred
//                // - lastValidLocation is the last found location (if any) regardless specified accuracy level
//                print("lastValidLocation = \(lastValidLocation)")
//                self.location.latitude = (lastValidLocation?.coordinate.latitude)!
//                self.location.longitude = (lastValidLocation?.coordinate.longitude)!
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location.latitude = location.coordinate.latitude
            self.location.longitude = location.coordinate.longitude
            print("Found user's location: \(location)")
            
            PFUser.currentUser()![kPAPUserLocationKey] = self.location
            PFUser.currentUser()?.saveEventually()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func textViewDidEndEditing(textView: UITextView) {
//        let object:PFObject = receiveData as! PFObject
        let object:PFObject = PFObject.init(className: kPAPAskMoneyClassKey)
        object[kPAPAskMoneyKey] = receiveData!             //金額數值
        object[kPAPAskMoneyFromUserKey] = PFUser.currentUser()      //誰請求
        object[kPAPAskMoneyContentKey]  =  textView.text     //請求內文
        if location.latitude == 0.0 && location.longitude == 0.0 {
            object[kPAPAskMoneyLocationKey] = PFUser.currentUser()![kPAPUserLocationKey]
        } else {
            object[kPAPAskMoneyLocationKey] = location
        }
        
        
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud?.labelText = "Upload Ask Money..."
        hud?.dimBackground = true
        
        object.saveEventually { (success, error) in
            if success {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.navigationController?.popToRootViewControllerAnimated(true)
                
                //然後再跳出7-11資訊。
                let how = self.navigationController?.viewControllers[0] as! HowMuchMoneyYouWantViewController
                how.askSend = true
            }
        }
        
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
