//
//  ApiOperation.swift
//  Kenko
//
//  Created by i_alexchen1 on 2016/8/24.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit

class ApiOperation: NSOperation {
    
    var manager: ApiManager?
    var saveObject: PFObject?
    var language: String?
    var result: AnyObject?
    
    init(manager: ApiManager, saveObject: PFObject, language: String) {
        self.manager = manager
        self.saveObject = saveObject
        self.language = language
    }
    
    override func main() {
        //檢查目前動作是否在主執行緒上
//        assert(NSThread.isMainThread())
        
        if cancelled {
            return
        }
        
        callApi(self.saveObject!, language: self.language!)
    }
    
    func callApi(saveObject: PFObject, language: String) -> AnyObject {
        
        manager?.postSentimentAnalysisText(saveObject, language: language).continueWithBlock({ (task) -> AnyObject! in
            if task.cancelled {
                // the save was cancelled.
            } else if task.error != nil {
                // the save failed.
            } else {
                // the object was saved successfully.
                self.result = task.result
            }
            return nil
        })
        
        return self.result!
    }
}
