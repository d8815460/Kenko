//
//  WriteTableViewController.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/13.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import MBProgressHUD

class WriteTableViewController: UITableViewController, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {

    private var hasPhoto:Bool?
    private var coundownNumber:Int?
    private var hud:MBProgressHUD?
    private var titleLabel:UILabel?
    private var fileMeiumImage:PFFile?
    private var fileSmallRoundedImage:PFFile?
    
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postSubTitle: UILabel!
    @IBOutlet weak var postTitleCheckMark: UILabel!
    
    @IBOutlet weak var postDetail: UILabel!
    @IBOutlet weak var postSubDetail: UILabel!
    @IBOutlet weak var postDetailCheckMark: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoCheckMark: UILabel!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.titleLabel = UILabel.init(frame: CGRectMake(0, 0, 168, 40))
        self.titleLabel?.textColor = UIColor.orangeColor()
        self.titleLabel?.backgroundColor = UIColor.clearColor()
        self.titleLabel?.font = UIFont.init(name: "ProximaNova-Bold", size: 17)
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = self.titleLabel
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        coundownNumber = 3
        
        var cell:UITableViewCell = UITableViewCell.init()
        var index:NSIndexPath = NSIndexPath.init()
        print("_data = \(postObject)")
        
        if postObject != nil {
            
            if (postObject!.objectForKey(kPAPPostsTitleKey) != nil) {
                index = NSIndexPath.init(forRow: 0, inSection: 0)
                cell = self.tableView.cellForRowAtIndexPath(index)!
                
                self.postTitle.text = "標題：\(postObject!.objectForKey(kPAPPostsTitleKey)!)"
                self.postTitle.textColor = UIColor.blackColor()
                self.postSubTitle.text = nil
                self.postTitleCheckMark.hidden = false
                coundownNumber = coundownNumber! - 1
            }
            
            if (postObject!.objectForKey(kPAPPostsContentKey) != nil) {
                index = NSIndexPath.init(forRow: 1, inSection: 0)
                cell = self.tableView.cellForRowAtIndexPath(index)!
                
                self.postDetail.text = "內容：\(postObject!.objectForKey(kPAPPostsContentKey)!)"
                self.postDetail.textColor = UIColor.blackColor()
                self.postSubTitle.text = nil
                self.postDetailCheckMark.hidden = false
                coundownNumber = coundownNumber! - 1
            }
            
            if (postObject!.objectForKey(kPAPPostsPhotoKey) != nil) {
                hasPhoto = true
                let photoFile = postObject!.objectForKey(kPAPPostsPhotoKey)
                photoFile?.getDataInBackgroundWithBlock({ (data, error) in
                    self.photoView.image = UIImage.init(data: data!)
                })
                self.photoLabel.hidden = true
                self.photoCheckMark.hidden = false
                coundownNumber = coundownNumber! - 1
            } else {
                hasPhoto = false
                self.photoLabel.hidden = false
                self.photoCheckMark.hidden = true
            }
        }
        
        
        
        if coundownNumber == 3 {
            self.titleLabel?.text = "還有三步便可以發布"
        } else if coundownNumber == 2 {
            self.titleLabel?.text = "還有兩步便可以發布"
        } else if coundownNumber == 1 {
            self.titleLabel?.text = "還有一步便可以發布"
        } else if coundownNumber == 0 {
            self.titleLabel?.text = "準備發布！"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        let cameraDeviceAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        let photoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        
        if cameraDeviceAvailable && photoLibraryAvailable {
            let actionSheet = UIActionSheet.init(title: nil, delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: "take a photo", "chose a photo", "dont use any photo")
            actionSheet.showInView(self.view)
        } else {
            self.shouldPresentPhotoCaptureController()
        }
    }

    func shouldPresentPhotoCaptureController() -> Bool {
        var presentedPhotoCapture = self.shouldStartCameraController
        
        if presentedPhotoCapture() == false {
            presentedPhotoCapture = self.shouldStartPhotoLibraryPickerController
        }
        return presentedPhotoCapture()
    }
    
    func shouldStartCameraController() -> Bool {
        return true
    }
    
    func shouldStartPhotoLibraryPickerController() -> Bool {
        return true
    }
    
    
    // MARK: - Image Picker Delegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.photoView.image = image
        hasPhoto = true
        
        let mediumImage = self.photoView.image!.thumbnailImage(640, transparentBorder: 0, cornerRadius: 0, interpolationQuality: CGInterpolationQuality.High)
        let smallRoundedImage = self.photoView.image!.thumbnailImage(120, transparentBorder: 0, cornerRadius: 0, interpolationQuality: CGInterpolationQuality.Low)
        
        let mediumImageData = UIImagePNGRepresentation(mediumImage)
        let smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage)
        
        //開始上傳檔案
        if hasPhoto == true {
            if mediumImageData?.length > 0 {
                let fileMeiumImage = PFFile.init(data: mediumImageData!)
                postObject![kPAPPostsPhotoKey] = fileMeiumImage
            }
            
            if smallRoundedImageData?.length > 0 {
                let fileSmallRoundedImage = PFFile.init(data: smallRoundedImageData!)
                postObject![kPAPPostsThumbnailKey] = fileSmallRoundedImage
            }
        }
    }
    
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.shouldStartCameraController()
        } else if buttonIndex == 1 {
            self.shouldStartPhotoLibraryPickerController()
        } else if buttonIndex == 2 {
            self.photoView.image = UIImage.init(named: "camera2")
            hasPhoto = false
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if coundownNumber == 0 {
            return 3
        } else if coundownNumber == 1 && hasPhoto == false {
            self.titleLabel?.text = "準備發布！"
            return 3
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.performSegueWithIdentifier("setTitle", sender: postObject)
        } else if indexPath.row == 1 {
            self.performSegueWithIdentifier("setDetail", sender: postObject)
        } else if indexPath.row == 2 {
            self.postPosts()
        }
    }

    
    func postPosts() {
        
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud?.labelText = "Save post ..."
        hud?.dimBackground = true
        
        let saveObject = postObject!
        
        let ACL:PFACL = PFACL()
        ACL.setPublicReadAccess(true)
        ACL.setPublicWriteAccess(true)
        saveObject.ACL = ACL
        
        saveObject[kPAPPostsUserKey] = PFUser.currentUser()
        saveObject.saveEventually { (successed, error) in
            if successed {
                print("Posts uploaded.")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("error upload post: \(error.debugDescription)")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).presentToTabbarIndex(0)
    }
    
    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "setTitle" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let titleView = storyboard.instantiateViewControllerWithIdentifier("title") as! WriteTitleViewController
            if postObject != nil {
                titleView.setDetailItem(postObject!)
            }
            
            
        } else if segue.identifier == "setDetail" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailView = storyboard.instantiateViewControllerWithIdentifier("detail") as! WriteDetailViewController
            if postObject != nil {
                detailView.setDetailItem(postObject!)
            }
        }
    }
    

}
