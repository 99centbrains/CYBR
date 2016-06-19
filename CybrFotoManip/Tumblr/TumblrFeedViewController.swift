//
//  TumblrFeedViewController.swift
//  CybrFotoManip
//
//  Created by Franky Aguilar on 12/3/15.
//  Copyright © 2015 99centbrains. All rights reserved.
//

import Foundation
import UIKit
import TMTumblrSDK
import SwiftyJSON

class TumblrFeedViewController:UIViewController {
    
    var array_posts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TMAPIClient.sharedInstance().OAuthConsumerKey = "c5GyLE1sxb1h7DIcAQu3Dum6ALeZGMssHuaL2XWv0es5Ayhh6S"
        TMAPIClient.sharedInstance().posts("cybrfm.99centbrains.com", type: "photo", parameters:
            ["limit" : 20, "offset" : 0, "filter" : "raw"]) { (result:AnyObject!, error:NSError!) -> Void in
                
                if (error == nil){
                    
                    print(result)
               
                }
        }
        
    }
    
    @IBAction func iba_dismiss(sender:UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        //
    }


}