//
//  SevenViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/20.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import MapKit
class SevenViewController: UIViewController, MKMapViewDelegate {

    var receiveData: AnyObject!
    
    @IBOutlet weak var thanksLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        mapView.showsUserLocation = true
        
        let userGeo = PFUser.currentUser()![kPAPUserLocationKey] as! PFGeoPoint
        let userLocation = CLLocationCoordinate2DMake(userGeo.latitude, userGeo.longitude)
        let region = MKCoordinateRegionMakeWithDistance(userLocation, 2000, 2000)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let Query7 = PFQuery.init(className: kPAPStoreClassKey)
        Query7.whereKey(kPAPStoreLocationKey, nearGeoPoint: PFUser.currentUser()?[kPAPUserLocationKey] as! PFGeoPoint)
        Query7.getFirstObjectInBackgroundWithBlock { (store, error) in
            
            self.thanksLabel.text = "您好，感謝您使用PiggyBank，以為您找尋離你家最近的7-11（\(store![kPAPStoreNameKey]!)），請就近領取您的救助金。"
            self.addressLabel.text = "地址：\(store![kPAPStoreAddressKey]!)"
            let sevenGEO:PFGeoPoint = store![kPAPStoreLocationKey] as! PFGeoPoint
            let sevenLocation = CLLocationCoordinate2DMake(sevenGEO.latitude, sevenGEO.longitude)
            
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = sevenLocation
            dropPin.title = "\(store![kPAPStoreNameKey]!)店"
            self.mapView.addAnnotation(dropPin)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takeMoneButtonPressed(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).setHowViewControllerAskSendFalse()
        
        
        self.dismissViewControllerAnimated(true) {
            
            
            
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        if (annotation.isKindOfClass(MKAnnotation)) {
            mapView.translatesAutoresizingMaskIntoConstraints = false
            let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomAnnotation") as MKAnnotationView!
            
            annotationView.annotation = annotation
            
            return annotationView
        } else {
            return nil
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
