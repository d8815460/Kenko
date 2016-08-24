//
//  ApiManager.swift
//  Kenko
//
//  Created by i_alexchen1 on 2016/8/23.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import Bolts
import AFNetworking

class ApiManager: NSObject {
    let baseURL = "https://api.havenondemand.com/1/api/sync/analyzesentiment/v1"
    let manager = AFHTTPSessionManager()
    
    
    func postSentimentAnalysisText(saveObject: PFObject, language: String) -> BFTask {
        let source = BFTaskCompletionSource()
        let url = "\(baseURL)"
        
        let parameters = NSMutableDictionary()
        parameters.setObject(saveObject[kPAPPostsContentKey] as! String, forKey: kPAPTEXTKEY)
        parameters.setObject(language, forKey: kPAPLANGUAGEKEY)
        parameters.setObject("75739c75-ad38-4f35-9261-a85d2a4b08f2", forKey: kPAPHPEAPIKEY)
        
        manager.POST(url, parameters: parameters, progress: { (progress) in
                print("progress = \(progress)")
            }, success: { (task, respondObject) in
                let dic = respondObject as! NSDictionary
                source.setResult(dic)
            }) { (task, error) in
                source.setError(error)
        }
        
        return source.task
    }
}
